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
		var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var capturedImage: UIImage?
		@Published var capturedVideo: URL?
		@Published var previewImage: UIImage?
		
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
			Task {
				try await Task.sleep(for: .seconds(0.5))
				if !self.isCapturingImage && self.capturedImage == nil {
					self.captureClient.startVideoRecording()
				}
			}
		}
		
		func didReleaseShutter() {
			if captureClient.isRecording {
				captureClient.stopVideoRecording()
			} else {
				captureClient.capture()
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
	}
}
