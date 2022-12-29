//
//  CaptureClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-28.
//

import AVFoundation
import Foundation

protocol CaptureClientProtocol {
	
}

class CaptureClient: CaptureClientProtocol {
	private let sessionQueue = DispatchQueue(label: "com.strikingFinancial.tribes.capture.sessionQueue", qos: .userInteractive)
	
	private enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
	}
	
	private let captureDevice: AVCaptureDevice?
	private let captureSession: AVCaptureSession
	
	private var hasAddedIO: Bool
	private var setupResult: SessionSetupResult
	
	init() {
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
		self.captureSession = AVCaptureSession()
		
		self.hasAddedIO = false
		self.setupResult = .success
	}
	
	private func setUp() {
		//Check camera permission before attempting setup
		switch PermissionClient.shared.checkCameraPermission() {
		case .allowed:
			break
		case .undetermined, .denied:
			setupResult = .notAuthorized
			return
		}
		
		//Add Input to Capture Session
		
	}
	
	private func addInput() throws {
		do {
			guard let captureDevice = self.captureDevice else { return }
			captureSession.beginConfiguration()
			captureSession.sessionPreset = .photo
		} catch {
			
		}
	}
	
	private func addOutput() {
		
	}
}
