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
		enum Sheet: Equatable {
			case imagePicker
		}
		
		private (set) var captureClient: CaptureClient = CaptureClient()
		
		@Published var audioPermissionState: PermissionState
		@Published var cameraPermissionState: PermissionState
		@Published var capturedImage: UIImage?
		@Published var capturedVideo: URL?
		@Published var previewImage: UIImage?
		@Published var selectedImage: UIImage?
		@Published var sheet: Sheet?
		
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
		
		var permissionText: String {
			if isPermissionDenied { return "You cannot share tea without your camera and microphone" }
			else { return "Use your camera and microphone to share tea with your tribes" }
		}
		
		var setUpResult: CaptureClient.SessionSetupResult {
			captureClient.setupResult
		}
		
		var videoRecordingProgress: Double {
			captureClient.recorderDuration / SizeConstants.maxVideoRecordingDuration
		}
		
		//Clients
		let feedbackClient = FeedbackClient.shared
		let permissionClient = PermissionClient.shared
		
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
			
			$selectedImage
				.receive(on: DispatchQueue.main)
				.sink(receiveValue: { [weak self] selectedImage in
					self?.capturedImage = selectedImage?
						.scaled(toFit: SizeConstants.imagePixelSize)
						.fillBackground(targetSize: SizeConstants.imagePixelSize, color: selectedImage?.averageColor ?? UIColor.lightGray)
						.resizedTo(megaBytes: SizeConstants.imageMaxSizeInMb)
				})
				.store(in: &cancellables)
		}
		
		func cancelVideoRecordingAndInvalidateTimer() {
			self.captureClient.cancelVideoRecording()
			self.videoRecorderTimer?.invalidate()
			self.videoRecorderTimer = nil
		}
		
		func close() {
			NotificationCenter.default.post(Notification(name: .toggleCompose))
			self.feedbackClient.medium()
		}
		
		func didAppear() {
			cancelVideoRecordingAndInvalidateTimer()
			resetCaptureValues()
			self.captureClient.startCaptureSession()
		}
		
		func didDisappear() {
			cancelVideoRecordingAndInvalidateTimer()
			resetCaptureValues()
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
			if cameraPermissionState == .allowed && audioPermissionState == .allowed {
				self.objectWillChange.send()
				self.captureClient = CaptureClient()
				self.addObservers()
				self.didAppear()
			}
		}
		
		func openSystemSettings() {
			permissionClient.openSystemSettings()
		}
		
		func toggleFlash() {
			self.captureClient.toggleFlash()
			FeedbackClient.shared.light()
		}
		
		func recordVideo() async {
			try? await Task.sleep(for: .seconds(0.2))
			self.captureClient.startVideoRecording()
		}
		
		func requestCameraAccess() {
			Task {
				switch cameraPermissionState {
				case .undetermined:
					self.cameraPermissionState = await permissionClient.requestCameraPermission()
					initializeCaptureClient()
				case .denied, .allowed:
					openSystemSettings()
				}
			}
		}
		
		func requestMicrophoneAccess() {
			Task {
				switch audioPermissionState {
				case .undetermined:
					self.audioPermissionState = await permissionClient.requestRecordPermission()
					initializeCaptureClient()
				case .denied, .allowed:
					openSystemSettings()
				}
			}
		}
		
		func resetCaptureValues() {
			self.capturedImage = nil
			self.capturedVideo = nil
			self.previewImage = nil
		}
		
		func openNoteCompose() {
			self.feedbackClient.medium()
			NotificationCenter.default.post(Notification(name: .openNoteCompose))
		}
		
		func setSheet(_ sheet: Sheet?) {
			self.sheet = sheet
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
