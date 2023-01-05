//
//  CaptureClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-28.
//

import AVFoundation
import Combine
import Foundation
import UIKit

protocol CaptureClientProtocol {
	var captureValuePublisher: AnyPublisher<CaptureClient.CaptureValue, Never> { get }
	func capture()
	func resumeCaptureSession()
	func startCaptureSession()
	func stopCaptureSession()
	func startVideoRecording()
	func stopVideoRecording()
	func toggleCamera()
	func toggleFlash()
}

class CaptureClient:
	NSObject,
	CaptureClientProtocol,
	AVCaptureVideoDataOutputSampleBufferDelegate,
	AVCapturePhotoCaptureDelegate,
	RecorderDelegate {
	private let sessionQueue = DispatchQueue(label: "com.strikingFinancial.tribes.capture.sessionQueue", qos: .userInteractive)
	private let dataOutputQueue = DispatchQueue(label: "com.strikingFinancial.tribes.capture.DataOutputQueue", qos: .userInteractive)
	
	private let frontDevice: AVCaptureDevice? = {
		if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
			return frontCameraDevice
		} else {
			return nil
		}
	}()
	
	private let backDevice: AVCaptureDevice? = {
		if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
			return dualCameraDevice
		} else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
			// If a rear dual camera is not available, default to the rear dual wide camera.
			return dualWideCameraDevice
		} else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
			// If a rear dual wide camera is not available, default to the rear wide angle camera.
			return backCameraDevice
		} else {
			return nil
		}
	}()
	
	private var capturePhotoSettings: AVCapturePhotoSettings {
		let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
		photoSettings.flashMode = captureFlashMode
		return photoSettings
	}
	
	private var cancellables = Set<AnyCancellable>()
	
	private var captureDevice: AVCaptureDevice?
	private var captureDeviceInput: AVCaptureDeviceInput?
	private let capturePhotoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
	private var captureVideoDataOutput: AVCaptureVideoDataOutput?
	private let captureSession: AVCaptureSession = AVCaptureSession()
	private let captureValueSubject = PassthroughSubject<CaptureValue, Never>()
	private var isSessionRunning: Bool = false
	
	private var recorder: Recorder?
	
	var captureFlashMode: AVCaptureDevice.FlashMode = .off
	var captureMode: CaptureMode = .imageAndVideo
	var isCapturingImage: Bool = false
	var isRecording: Bool = false
	var setupResult: SessionSetupResult = .success
	var recorderDuration: Double = 0
	
	//MARK: Computed properties
	var captureValuePublisher: AnyPublisher<CaptureValue, Never> {
		return captureValueSubject
			.subscribe(on: sessionQueue)
			.eraseToAnyPublisher()
	}
	
	override init() {
		self.captureDevice = backDevice
		
		super.init()
		
		setUp()
	}
	
	private func setUp() {
		//Check camera permission before attempting setup
		switch PermissionClient.shared.checkCameraPermission() {
		case .allowed:
			break
		case .undetermined, .denied:
			self.setupResult = .notAuthorized
			return
		}
		
		//Add Input and Output to Capture Session
		do {
			captureSession.beginConfiguration()
			try addInput()
			try addOutput()
			captureSession.commitConfiguration()
		} catch {
			captureSession.commitConfiguration()
			self.setupResult = .configurationFailed
			print("Camera Setup Failed: \(error.localizedDescription)")
		}
	}
	
	private func addInput() throws {
		guard let captureDevice = self.captureDevice else {
			throw AppError.CaptureClientError.noCaptureDevice
		}
		captureSession.automaticallyConfiguresApplicationAudioSession = false
		captureSession.sessionPreset = .hd1920x1080
		
		let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
		
		if captureSession.canAddInput(captureDeviceInput) {
			captureSession.addInputWithNoConnections(captureDeviceInput)
			self.captureDeviceInput = captureDeviceInput
		} else {
			throw AppError.CaptureClientError.couldNotAddVideoInput
		}
	}
	
	private func addOutput() throws {
		//Add photo output
		if captureSession.canAddOutput(capturePhotoOutput) {
			captureSession.addOutput(capturePhotoOutput)
		} else {
			throw AppError.CaptureClientError.couldNotAddPhotoOutput
		}
		self.captureVideoDataOutput?.setSampleBufferDelegate(nil, queue: nil)
		
		//Add video output
		let videoDataOutput = AVCaptureVideoDataOutput()
		videoDataOutput.setSampleBufferDelegate(self, queue: self.dataOutputQueue)
		videoDataOutput.alwaysDiscardsLateVideoFrames = true
		self.captureVideoDataOutput = videoDataOutput
		
		guard let captureVideoDataOutput = self.captureVideoDataOutput,
			  captureSession.canAddOutput(captureVideoDataOutput) else {
			throw AppError.CaptureClientError.couldNotAddVideoOutput
		}
		captureSession.addOutputWithNoConnections(captureVideoDataOutput)
		
		//Add connection
		guard let ports = captureDeviceInput?.ports else { throw AppError.CaptureClientError.couldNotAddPorts }
		
		let dataConnection = AVCaptureConnection(inputPorts: ports, output: captureVideoDataOutput)
		if dataConnection.isVideoOrientationSupported {
			dataConnection.videoOrientation = .portrait
		}
		if dataConnection.isVideoMirroringSupported {
			dataConnection.isVideoMirrored = captureDevice?.position == .front
		}
		
		if captureSession.canAddConnection(dataConnection) {
			captureSession.addConnection(dataConnection)
		} else {
			throw AppError.CaptureClientError.couldNotAddDataConnection
		}
	}
	
	private func addObservers() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(captureSessionRuntimeError),
			name: .AVCaptureSessionRuntimeError,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(captureSessionInterrupted),
			name: .AVCaptureSessionWasInterrupted,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(captureSessionInterruptionEnded),
			name: .AVCaptureSessionInterruptionEnded,
			object: nil
		)
		
		NotificationCenter
			.default
			.addObserver(
				forName: UIApplication.didEnterBackgroundNotification,
				object: nil,
				queue: .main,
				using: { [weak self] _ in
					self?.flushBuffer()
				}
			)
	}
	
	private func flushBuffer() {
		captureValueSubject.send(.previewImageBuffer(nil))
	}
	
	private func removeSessionIO() {
		sessionQueue.async {
			self.captureSession.inputs.forEach(self.captureSession.removeInput)
			self.captureSession.outputs.forEach(self.captureSession.removeOutput)
			self.captureSession.connections.forEach(self.captureSession.removeConnection)
		}
	}
	
	public func capture() {
		#if !targetEnvironment(simulator)
		self.isCapturingImage = true
		capturePhotoOutput.capturePhoto(
			with: capturePhotoSettings,
			delegate: self
		)
		#endif
	}
	
	func resetZoomFactor() {
		updateZoomFactor(low: 1.0, high: 1.0)
	}
	
	func resumeCaptureSession() {
		if self.isSessionRunning {
			self.stopCaptureSession()
			self.flushBuffer()
			self.setUp()
			self.startCaptureSession()
			self.captureMode = .imageAndVideo
		}
	}
	
	func setTorchMode(mode: AVCaptureDevice.TorchMode) {
		guard
			let captureDevice = self.captureDevice,
			mode != .auto
		else { return }
		do {
			try captureDevice.lockForConfiguration()
			try captureDevice.setTorchModeOn(level: 1.0)
			captureDevice.torchMode = mode
			captureDevice.unlockForConfiguration()
		} catch {
			print("Could not set torch mode")
		}
	}
	
	func startCaptureSession() {
		sessionQueue.async {
			self.resetZoomFactor()
			self.captureSession.startRunning()
			self.isSessionRunning = self.captureSession.isRunning
		}
	}
	
	func stopCaptureSession() {
		sessionQueue.async {
			self.stopVideoRecording()
			self.captureSession.stopRunning()
			self.isSessionRunning = self.captureSession.isRunning
		}
	}
	
	func startVideoRecording() {
		Task(priority: .userInitiated) {
			do {
				guard
					!self.isRecording,
					let captureDevice = self.captureDevice,
					let captureVideoDataOutput = self.captureVideoDataOutput,
					let videoSettings = captureVideoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4)
				else {
					throw AppError.CaptureClientError.failedToGenerateVideoSettings
				}
				
				//Use Torch if the flash mode is on
				if captureDevice.hasTorch && self.captureFlashMode == .on {
					setTorchMode(mode: .on)
				}
				
				let new = Recorder()
				new.startVideoRecording(videoSettings: videoSettings)
				new.delegate = self
				self.recorder = new
			} catch {
				print("Video Recording Failed Failed: \(error.localizedDescription)")
			}
		}
	}
	
	func stopVideoRecording() {
		guard
			isRecording,
			let recorder = self.recorder
		else { return }
		
		self.setTorchMode(mode: .off)
		
		recorder
		.stopRecording()
		.sink(
			receiveCompletion: { _ in },
			receiveValue: { [weak self] url in
				self?.captureValueSubject.send(.video(url))
			}
		)
		.store(in: &self.cancellables)
	}
	
	func toggleCamera() {
		guard let currentDevicePosition = self.captureDevice?.position,
			  let oppositeDevice: AVCaptureDevice = currentDevicePosition == .back ? frontDevice : backDevice
		else { return }
		
		self.captureSession.beginConfiguration()
		removeSessionIO()
		self.captureDevice = oppositeDevice
		try? addInput()
		try? addOutput()
		self.captureSession.commitConfiguration()
	}
	
	func toggleFlash() {
		let currentFlashMode = self.captureFlashMode
		self.captureFlashMode = currentFlashMode == .on ? .off : .on
	}
	
	func updateZoomFactor(low: CGFloat, high: CGFloat) {
		guard let currentDevice = captureDevice else { return }
		do {
			try currentDevice.lockForConfiguration()
			var zoomFactor = (low - high) / 50
			
			if (zoomFactor < 1) {
				zoomFactor = 1
			}
			currentDevice.videoZoomFactor = zoomFactor
			currentDevice.unlockForConfiguration()
		}
		catch {	}
	}
	
	// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		if let recorder = recorder, recorder.isRecording {
			recorder.recordVideo(sampleBuffer: sampleBuffer)
		}
		captureValueSubject.send(.previewImageBuffer(sampleBuffer))
	}
	
	// MARK: - AVCapturePhotoCaptureDelegate
	func photoOutput(
		_ output: AVCapturePhotoOutput,
		didFinishProcessingPhoto photo: AVCapturePhoto,
		error: Error?
	) {
		guard let position = output.connections.first?.inputPorts.first?.sourceDevicePosition else { return }
		
		guard
			let image = photo.fileDataRepresentation().flatMap(UIImage.init),
			let cgImage = image.cgImage
		else { return }
		
		var captured: UIImage
		
		func flippedImage(_ image: CGImage) -> UIImage {
			let ciImage = CIImage(cgImage: image).oriented(forExifOrientation: 6)
			let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
			return .init(cgImage: CaptureClient.context.createCGImage(flippedImage, from: flippedImage.extent)!)
		}
		
		captured = position == .front ? flippedImage(cgImage) : image
		
		captureValueSubject.send(.image(captured))
		self.isCapturingImage = false
	}
	
	// MARK: - RecorderDelegate
	func recorderDidBeginRecording(_ recorder: Recorder) {
		self.isRecording = recorder.isRecording
	}
	
	func recorderDidUpdateRecordingDuration(_ recorder: Recorder, duration: Measurement<UnitDuration>) {
		recorderDuration = recorder.measurement.value
	}
	
	func recorderDidFinishRecording(_ recorder: Recorder) {
		self.isRecording = recorder.isRecording
		self.recorder = nil
		self.recorderDuration = 0.0
		self.resetZoomFactor()
	}
	
	// MARK: - Notifications
	@objc private func captureSessionRuntimeError(_ notification: Notification) {
		stopCaptureSession()
		flushBuffer()
		self.captureMode = .none
	}
	
	@objc private func captureSessionInterrupted(_ notification: NSNotification) {
		guard
			let reasonKey = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? Int,
			let reason = AVCaptureSession.InterruptionReason(rawValue: reasonKey)
		else { return }
		
		switch reason {
		case .audioDeviceInUseByAnotherClient:
			self.captureMode = .image
		default:
			self.captureMode = .none
		}
	}
	
	@objc private func captureSessionInterruptionEnded(_ notification: NSNotification) {
		resumeCaptureSession()
	}
}
