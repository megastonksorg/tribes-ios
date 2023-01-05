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
		
		let captureClient: CaptureClient = CaptureClient()
		
		@Published var capturedImage: UIImage?
		@Published var capturedVideo: URL?
		@Published var previewImage: UIImage?
		
		var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		var videoRecorderTimer: Timer?
		
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
		
		var videoRecordingProgress: Double {
			captureClient.recorderDuration / SizeConstants.maxVideoRecordingDuration
		}
		
		init() {
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
		
		func didAppear() {
			resetCaptureValues()
			self.captureClient.startCaptureSession()
		}
		
		func didDisappear() {
			self.captureClient.stopCaptureSession()
		}
		
		func didPressShutter() {
			let shutterButtonDelay: Double = SizeConstants.shutterButtonDelay
			
			videoRecorderTimer = Timer.scheduledTimer(
				timeInterval: SizeConstants.maxVideoRecordingDuration + shutterButtonDelay,
				target: self,
				selector: #selector(stopVideoRecordingIfRequiredAndInvalidateTimer),
				userInfo: nil,
				repeats: false
			)
			
			Task {
				try await Task.sleep(for: .seconds(shutterButtonDelay))
				if !self.isCapturingImage && self.capturedImage == nil {
					self.captureClient.startVideoRecording()
				}
			}
		}
		
		func didReleaseShutter() {
			if captureClient.isRecording {
				stopVideoRecordingIfRequiredAndInvalidateTimer()
			} else {
				captureClient.capture()
				stopVideoRecordingIfRequiredAndInvalidateTimer()
			}
		}
		
		func toggleFlash() {
			self.captureClient.toggleFlash()
			FeedbackClient.shared.light()
		}
		
		func resetCaptureValues() {
			self.capturedImage = nil
			self.capturedVideo = nil
			self.previewImage = nil
		}
		
		func updateZoomFactor(low: CGFloat, high: CGFloat) {
			if isRecordingVideo {
				self.captureClient.updateZoomFactor(low: low, high: high)
			}
		}
		
		@objc func stopVideoRecordingIfRequiredAndInvalidateTimer() {
			if self.isRecordingVideo {
				self.captureClient.stopVideoRecording()
			}
			videoRecorderTimer?.invalidate()
			videoRecorderTimer = nil
		}
	}
}
