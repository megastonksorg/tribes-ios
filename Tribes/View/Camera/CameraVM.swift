//
//  CameraVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-29.
//

import Combine
import Foundation
import SwiftUI

extension CameraView {
	@MainActor class ViewModel: ObservableObject {
		
		let permissionClient = PermissionClient.shared
		
		private (set) var captureClient: CaptureClient = CaptureClient()
		
		@Published var audioPermissionState: PermissionState
		@Published var cameraPermissionState: PermissionState
		@Published var capturedImage: UIImage?
		@Published var capturedVideo: URL?
		@Published var previewImage: UIImage?
		
		var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		var videoRecorderTimer: Timer?
		
		var isPermissionAllowed: Bool {
			cameraPermissionState == .allowed && audioPermissionState == .allowed
		}
		
		var isPermissionDenied: Bool {
			cameraPermissionState == .denied || audioPermissionState == .denied
		}
		
		var isPermissionUndetermined: Bool {
			cameraPermissionState == .undetermined || audioPermissionState == .undetermined
		}
		
		var cameraMode: CaptureClient.CaptureMode {
			captureClient.captureMode
		}
		
		var isFlashOn: Bool {
			captureClient.captureFlashMode == .on
		}
		
		var isCapturingImage: Bool {
			captureClient.isCapturingImage
		}
		
		var isRecordingVideo: Bool {
			captureClient.isRecording
		}
		
		var setUpResult: CaptureClient.SessionSetupResult {
			captureClient.setupResult
		}
		
		var videoRecordingProgress: Double {
			captureClient.recorderDuration / SizeConstants.maxVideoRecordingDuration
		}
		
		init() {
			self.audioPermissionState = permissionClient.checkRecordPermission()
			self.cameraPermissionState = permissionClient.checkCameraPermission()
			addObservers()
		}
		
		func addObservers() {
			captureClient.captureValuePublisher
				.receive(on: DispatchQueue.main)
				.sink(receiveValue: { [weak self] captureValue in
					switch captureValue {
					case .image(let image):
						self?.capturedImage = image
					case .previewImageBuffer(let sampleBuffer):
						guard let image = sampleBuffer?.image() else { return }
						self?.previewImage = image
					case .video(let url):
						self?.capturedVideo = url
					}
				})
				.store(in: &cancellables)
		}
		
		func cancelVideoRecordingAndInvalidateTimer() {
			self.captureClient.cancelVideoRecording()
			self.videoRecorderTimer?.invalidate()
			self.videoRecorderTimer = nil
		}
		
		func didAppear() {
			resetCaptureValues()
			self.captureClient.startCaptureSession()
		}
		
		func didDisappear() {
			self.captureClient.stopCaptureSession()
		}
		
		func didPressShutter() {
			cancelVideoRecordingAndInvalidateTimer()
			videoRecorderTimer = Timer.scheduledTimer(
				timeInterval: SizeConstants.maxVideoRecordingDuration,
				target: self,
				selector: #selector(stopVideoRecordingAndInvalidateTimer),
				userInfo: nil,
				repeats: false
			)
			
			Task {
				await recordVideo()
			}
		}
		
		func didReleaseShutter() {
			guard let videoRecorderTimer = self.videoRecorderTimer else { return }
			let recordedDurationAtThisMoment = videoRecorderTimer.fireDate.timeIntervalSince(Date.now)
			//Video recording will only be continued if the recording is more than 2 seconds
			if recordedDurationAtThisMoment > SizeConstants.maxVideoRecordingDuration - 3.0 {
				cancelVideoRecordingAndInvalidateTimer()
				captureClient.capture()
			} else {
				stopVideoRecordingAndInvalidateTimer()
			}
		}
		
		func initializeCaptureClient() {
			self.objectWillChange.send()
			self.captureClient = CaptureClient()
			self.addObservers()
			self.didAppear()
		}
		
		func openSystemSettings() {
			permissionClient.openSystemSettings()
		}
		
		func toggleFlash() {
			self.captureClient.toggleFlash()
			FeedbackClient.shared.light()
		}
		
		func recordVideo() async {
			try? await Task.sleep(for: .seconds(0.5))
			self.captureClient.startVideoRecording()
		}
		
		func requestCameraAccess() {
			Task {
				self.cameraPermissionState = await permissionClient.requestCameraPermission()
				self.audioPermissionState = await permissionClient.requestRecordPermission()
				
				if cameraPermissionState == .allowed && audioPermissionState == .allowed {
					initializeCaptureClient()
				}
			}
		}
		
		func resetCaptureValues() {
			self.capturedImage = nil
			self.capturedVideo = nil
			self.previewImage = nil
		}
		
		@objc func stopVideoRecordingAndInvalidateTimer() {
			self.captureClient.stopVideoRecording()
			videoRecorderTimer?.invalidate()
			videoRecorderTimer = nil
		}
		
		func updateZoomFactor(low: CGFloat, high: CGFloat) {
			if isRecordingVideo {
				self.captureClient.updateZoomFactor(low: low, high: high)
			}
		}
	}
}
