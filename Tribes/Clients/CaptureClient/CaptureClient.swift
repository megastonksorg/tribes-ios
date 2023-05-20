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
	func cancelVideoRecording()
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
	AVCaptureAudioDataOutputSampleBufferDelegate,
	AVCaptureVideoDataOutputSampleBufferDelegate,
	AVCapturePhotoCaptureDelegate,
	RecorderDelegate {
	private let sessionQueue = DispatchQueue(label: "com.strikingFinancial.tribes.capture.sessionQueue", qos: .userInteractive)
	private let dataOutputQueue = DispatchQueue(label: "com.strikingFinancial.tribes.capture.DataOutputQueue", qos: .userInteractive)
	
	private let frontDevice: AVCaptureDevice? = {
		if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
			frontCameraDevice.activeVideoMinFrameDuration = frameDuration
			frontCameraDevice.activeVideoMaxFrameDuration = frameDuration
			return frontCameraDevice
		} else {
			return nil
		}
	}()
	
	private let backDevice: AVCaptureDevice? = {
		let backCameraDevice: AVCaptureDevice? = {
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
		backCameraDevice?.activeVideoMinFrameDuration = frameDuration
		backCameraDevice?.activeVideoMaxFrameDuration = frameDuration
		return backCameraDevice
	}()
	
	private var capturePhotoSettings: AVCapturePhotoSettings {
		let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
		photoSettings.flashMode = captureFlashMode
		return photoSettings
	}
	
	private var cancellables = Set<AnyCancellable>()
	
	private var captureDevice: AVCaptureDevice?
	private var captureVideoDeviceInput: AVCaptureDeviceInput?
	private var captureAudioDeviceInput: AVCaptureDeviceInput?
	private let capturePhotoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
	private var captureAudioDataOutput: AVCaptureAudioDataOutput?
	private var captureVideoDataOutput: AVCaptureVideoDataOutput?
	private let captureSession: AVCaptureSession = AVCaptureSession()
	private let audioSession: AVCaptureSession = AVCaptureSession()
	private let captureValueSubject = PassthroughSubject<CaptureValue, Never>()
	
	private var recorder: Recorder?
	
	static let frameRate: Int32 = 30
	static private let frameDuration: CMTime = CMTime(value: 1, timescale: CMTimeScale(frameRate))
	
	var captureFlashMode: AVCaptureDevice.FlashMode = .off
	var captureMode: CaptureMode = .imageAndVideo
	var isCapturingImage: Bool = false
	var isRecording: Bool = false
	var isSessionRunning: Bool = false
	var isSwitchingCamera: Bool = false
	var setupResult: SessionSetupResult = .success
	var recorderDuration: Double = 0
	
	//MARK: Computed properties
	var captureValuePublisher: AnyPublisher<CaptureValue, Never> {
		return captureValueSubject
			.subscribe(on: sessionQueue)
			.eraseToAnyPublisher()
	}
	
	//Clients
	let permissionClient: PermissionClient = PermissionClient.shared
	
	override init() {
		self.captureDevice = frontDevice
		super.init()
	}
	
	private func setUp() {
		//Check camera permission before attempting setup
		switch permissionClient.checkCameraPermission() {
		case .allowed:
			break
		case .undetermined, .denied:
			self.setupResult = .notAuthorized
			return
		}
		
		//Check audio permission before attempting setup
		switch permissionClient.checkRecordPermission() {
		case .allowed:
			break
		case .undetermined, .denied:
			self.setupResult = .notAuthorized
			return
		}
		
		//Add Input and Output to Capture Session
		do {
			captureSession.beginConfiguration()
			captureSession.automaticallyConfiguresApplicationAudioSession = false
			
			self.audioSession.automaticallyConfiguresApplicationAudioSession = false
			self.audioSession.usesApplicationAudioSession = true
			
			try addInputAndOutput()
			captureSession.commitConfiguration()
		} catch {
			captureSession.commitConfiguration()
			self.setupResult = .configurationFailed
			print("Camera Setup Failed: \(error.localizedDescription)")
		}
	}
	
	private func addInputAndOutput() throws {
		guard let captureDevice = self.captureDevice else {
			throw AppError.CaptureClientError.noCaptureDevice
		}
		captureSession.sessionPreset = .hd1920x1080
		
		let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
		self.captureVideoDeviceInput = captureDeviceInput
		guard let captureVideoDeviceInput = self.captureVideoDeviceInput
		else { throw AppError.CaptureClientError.couldNotAddAudioDevice }
		
		// Add camera input
		if captureSession.canAddInput(captureVideoDeviceInput) {
			captureSession.addInputWithNoConnections(captureVideoDeviceInput)
		} else {
			throw AppError.CaptureClientError.couldNotAddVideoInput
		}
		
		//Add photo output
		if captureSession.canAddOutput(capturePhotoOutput) {
			captureSession.addOutput(capturePhotoOutput)
		} else {
			throw AppError.CaptureClientError.couldNotAddPhotoOutput
		}
		
		//Add video output
		self.captureVideoDataOutput?.setSampleBufferDelegate(nil, queue: nil)
		
		let videoDataOutput = AVCaptureVideoDataOutput()
		videoDataOutput.setSampleBufferDelegate(self, queue: self.dataOutputQueue)
		videoDataOutput.alwaysDiscardsLateVideoFrames = true
		self.captureVideoDataOutput = videoDataOutput
		
		guard let captureVideoDataOutput = self.captureVideoDataOutput,
			  captureSession.canAddOutput(captureVideoDataOutput) else {
			throw AppError.CaptureClientError.couldNotAddVideoOutput
		}
		captureSession.addOutputWithNoConnections(captureVideoDataOutput)
		
		//Add camera connection
		let dataConnection = AVCaptureConnection(inputPorts: captureVideoDeviceInput.ports, output: captureVideoDataOutput)
		if dataConnection.isVideoOrientationSupported {
			dataConnection.videoOrientation = .portrait
		}
		if dataConnection.isVideoMirroringSupported {
			dataConnection.isVideoMirrored = captureDevice.position == .front
		}
		
		if captureSession.canAddConnection(dataConnection) {
			captureSession.addConnection(dataConnection)
		} else {
			throw AppError.CaptureClientError.couldNotAddDataConnection
		}
	}
	
	private func addAudioInputAndOutput() {
		sessionQueue.async { [weak self] in
			guard let self = self else { return }
			
			//Add audio input
			let audioDeviceInput = try? AVCaptureDeviceInput(device: AVCaptureDevice.default(for: .audio)!)
			self.captureAudioDeviceInput = audioDeviceInput
			
			if let captureAudioDeviceInput = self.captureAudioDeviceInput,
			   self.audioSession.canAddInput(captureAudioDeviceInput) {
				self.audioSession.addInput(captureAudioDeviceInput)
			}
			
			//Add audio output
			self.captureAudioDataOutput?.setSampleBufferDelegate(nil, queue: nil)
			
			let audioDataOutput = AVCaptureAudioDataOutput()
			audioDataOutput.setSampleBufferDelegate(self, queue: self.dataOutputQueue)
			self.captureAudioDataOutput = audioDataOutput
			
			if let captureAudioDataOutput = self.captureAudioDataOutput,
			   self.audioSession.canAddOutput(captureAudioDataOutput) {
				self.audioSession.addOutput(captureAudioDataOutput)
			}
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
	
	func cancelVideoRecording() {
		self.recorderDuration = 0.0
		self.recorder = nil
		self.isRecording = false
		self.resetZoomFactor()
	}
	
	func capture() {
		#if !targetEnvironment(simulator)
		self.isCapturingImage = true
		capturePhotoOutput.capturePhoto(
			with: capturePhotoSettings,
			delegate: self
		)
		#endif
	}
	
	private func removeSessionIO(shouldRemoveAudioIO: Bool) {
		//Capture Session
		self.captureSession.inputs.forEach(self.captureSession.removeInput)
		self.captureSession.outputs.forEach(self.captureSession.removeOutput)
		self.captureSession.connections.forEach(self.captureSession.removeConnection)
		
		if shouldRemoveAudioIO {
			//Audio Session
			self.audioSession.inputs.forEach(self.audioSession.removeInput)
			self.audioSession.outputs.forEach(self.audioSession.removeOutput)
			self.audioSession.connections.forEach(self.audioSession.removeConnection)
		}
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
			if captureDevice.isTorchAvailable {
				try captureDevice.lockForConfiguration()
				try captureDevice.setTorchModeOn(level: 1.0)
				captureDevice.torchMode = mode
				captureDevice.unlockForConfiguration()
			}
		} catch {
			print("Could not set torch mode")
		}
	}
	
	func startCaptureSession() {
		sessionQueue.async {
			self.setUp()
			self.resetZoomFactor()
			self.captureSession.startRunning()
			self.audioSession.startRunning()
			self.isSessionRunning = self.captureSession.isRunning
		}
	}
	
	func stopCaptureSession() {
		sessionQueue.async {
			self.stopVideoRecording()
			self.audioSession.stopRunning()
			self.captureSession.stopRunning()
			self.isSessionRunning = self.captureSession.isRunning
			self.removeSessionIO(shouldRemoveAudioIO: true)
		}
	}
	
	func startVideoRecording() {
		Task(priority: .userInitiated) {
			do {
				let fileType = SizeConstants.videoFileType
				guard
					!self.isCapturingImage,
					!self.isRecording,
					let captureDevice = self.captureDevice,
					let captureVideoDataOutput = self.captureVideoDataOutput,
					var videoSettings = captureVideoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: fileType)
				else {
					throw AppError.CaptureClientError.failedToGenerateAudioAndVideoSettings
				}
				
				await SoundClient.shared.setAudioCategory(for: .record)
				self.audioSession.beginConfiguration()
				self.addAudioInputAndOutput()
				self.audioSession.commitConfiguration()
				//Video Settings
				videoSettings[AVVideoCompressionPropertiesKey] = [AVVideoAverageBitRateKey: 4_000_000]
				
				//Use Torch if the flash mode is on
				if captureDevice.hasTorch && self.captureFlashMode == .on {
					setTorchMode(mode: .on)
				}
				
				let new = Recorder()
				new.startVideoRecording(videoSettings: videoSettings, fileType: fileType)
				new.delegate = self
				self.recorder = new
			} catch {
				print("Video Recording Failed: \(error.localizedDescription)")
			}
		}
	}
	
	func stopVideoRecording() {
		guard let recorder = self.recorder else { return }
		recorder
			.stopRecording()
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { [weak self] url in
					self?.captureValueSubject.send(.video(url))
					Task(priority: .userInitiated) {
						await SoundClient.shared.setAudioCategory(for: .playback)
					}
				}
			)
			.store(in: &self.cancellables)
	}
	
	func toggleCamera() {
		guard let currentDevicePosition = self.captureDevice?.position,
			  let oppositeDevice: AVCaptureDevice = currentDevicePosition == .back ? frontDevice : backDevice
		else { return }
		self.isSwitchingCamera = true
		self.audioSession.beginConfiguration()
		self.captureSession.beginConfiguration()
		removeSessionIO(shouldRemoveAudioIO: self.isRecording)
		self.captureDevice = oppositeDevice
		try? addInputAndOutput()
		if self.isRecording {
			self.addAudioInputAndOutput()
		}
		self.audioSession.commitConfiguration()
		self.captureSession.commitConfiguration()
		self.isSwitchingCamera = false
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
			if output == self.captureAudioDataOutput && !self.isSwitchingCamera {
				recorder.recordAudio(sampleBuffer: sampleBuffer)
			}
			else { recorder.recordVideo(sampleBuffer: sampleBuffer) }
		}
		
		guard output != self.captureAudioDataOutput else { return }
		
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
		
		func getImage(_ image: CGImage, flip: Bool) -> UIImage {
			let ciImage = CIImage(cgImage: image).oriented(forExifOrientation: 6)
			if flip {
				let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
				return .init(cgImage: CaptureClient.context.createCGImage(flippedImage, from: flippedImage.extent)!)
			} else {
				return .init(cgImage: CaptureClient.context.createCGImage(ciImage, from: ciImage.extent)!)
			}
		}
		
		captured = position == .front ? getImage(cgImage, flip: true) : getImage(cgImage, flip: false)
		
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
