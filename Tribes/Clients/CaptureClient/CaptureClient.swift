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
	var captureValuePublisher: AnyPublisher<CaptureValue, Never> { get }
	func startCaptureSession()
	func stopCaptureSession()
}

class CaptureClient: NSObject, CaptureClientProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {
	private let sessionQueue = DispatchQueue(label: "com.strikingFinancial.tribes.capture.sessionQueue", qos: .userInteractive)
	private let dataOutputQueue = DispatchQueue(label: "com.strikingFinancial.tribes.capture.DataOutputQueue", qos: .userInteractive)
	
	private enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
	}
	
	private var captureDevice: AVCaptureDevice?
	private var captureDeviceInput: AVCaptureDeviceInput?
	private let capturePhotoOutput: AVCapturePhotoOutput
	private var captureVideoDataOutput: AVCaptureVideoDataOutput?
	private let captureSession: AVCaptureSession
	private let captureValueSubject = PassthroughSubject<CaptureValue, Never>()
	
	private var hasAddedIO: Bool
	private var setupResult: SessionSetupResult
	
	//MARK: Computed properties
	var captureValuePublisher: AnyPublisher<CaptureValue, Never> {
		return captureValueSubject
			.subscribe(on: sessionQueue)
			.eraseToAnyPublisher()
	}
	
	override init() {
		self.captureDevice = {
			if let tripleCameraDevice = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
				return tripleCameraDevice
			}
			else if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
				return dualCameraDevice
			} else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
				// If a rear dual camera is not available, default to the rear dual wide camera.
				return dualWideCameraDevice
			} else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
				// If a rear dual wide camera is not available, default to the rear wide angle camera.
				return backCameraDevice
			} else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
				// If the rear wide angle camera isn't available, default to the front wide angle camera.
				return frontCameraDevice
			} else {
				return nil
			}
		}()
		self.capturePhotoOutput = AVCapturePhotoOutput()
		self.captureSession = AVCaptureSession()
		
		self.hasAddedIO = false
		self.setupResult = .success
		
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
		
		//Add Input to Capture Session
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
			dataConnection.isVideoMirrored = false
		}

		if captureSession.canAddConnection(dataConnection) {
			captureSession.addConnection(dataConnection)
		} else {
			throw AppError.CaptureClientError.couldNotAddDataConnection
		}
	}
	
	func startCaptureSession() {
		sessionQueue.async {
			self.captureSession.startRunning()
		}
	}
	
	func stopCaptureSession() {
		sessionQueue.async {
			self.captureSession.stopRunning()
		}
	}
	
	// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		captureValueSubject.send(.previewImageBuffer(sampleBuffer))
	}
}
