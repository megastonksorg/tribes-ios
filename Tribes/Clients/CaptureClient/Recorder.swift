//
//  Recorder.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-03.
//

import AVFoundation
import Combine
import Foundation
import VideoToolbox

protocol RecorderDelegate: AnyObject {
	/// Fires when we receive the first valid video buffer
	func recorderDidBeginRecording(_ recorder: Recorder)
	
	/// Fires each time we update with a valid video buffer
	func recorderDidUpdateRecordingDuration(_ recorder: Recorder, duration: Measurement<UnitDuration>)
	
	/// Fires when we finish recording
	func recorderDidFinishRecording(_ recorder: Recorder)
}

final class Recorder {
	weak var delegate: RecorderDelegate?
	
	private(set) var isRecording = false
	private(set) var measurement: Measurement<UnitDuration> = Measurement<UnitDuration>(value: 0, unit: .seconds)
	
	private var assetWriter: AVAssetWriter?
	private var assetWriterVideoInput: AVAssetWriterInput?
	private var assetWriterAudioInput: AVAssetWriterInput?
	private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
	
	private var frameCount = 0
	private var frameRate: Int32 = CaptureClient.frameRate
	
	private var hasReceivedVideoBuffer = false
	
	private var lastKnownBufferTimestamp: CMTime?
	
	private var previousPresentationTimeStamp: CMTime = .zero
	private var startingPresentationTimeStamp: CMTime = .zero
	
	// MARK: - Recording
	func startVideoRecording(videoSettings: [String : Any]?, fileType: AVFileType) {
		let fileName = UUID().uuidString + (fileType == .mp4 ? ".mp4" : ".null")
		let fileUrl = FileManager.default.temporaryDirectory.appending(path: fileName)
		
		guard let writer = try? AVAssetWriter(outputURL: fileUrl, fileType: fileType) else { return }
		
		writer.shouldOptimizeForNetworkUse = true
		
		//Add audio input
		let audioSettings = [
			AVFormatIDKey: kAudioFormatMPEG4AAC,
			AVNumberOfChannelsKey: 2,
			AVSampleRateKey: 44100
		]
		let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
		audioInput.expectsMediaDataInRealTime = true
		writer.add(audioInput)
		assetWriterAudioInput = audioInput
		
		//Add video input
		let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
		videoInput.expectsMediaDataInRealTime = true
		writer.add(videoInput)
		assetWriterVideoInput = videoInput
		
		//Create and assign the Buffer Adaptor
		guard let assetWriterVideoInput = self.assetWriterVideoInput else { return }
		self.assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterVideoInput, sourcePixelBufferAttributes: nil)
		
		assetWriter = writer
		isRecording = true
	}
	
	func stopRecording() -> AnyPublisher<URL, AppError.RecorderError> {
		self.isRecording = false
		let passThroughSubject = PassthroughSubject<URL, AppError.RecorderError>()
		guard
			let assetWriter = assetWriter,
			let lastKnownBufferTimestamp
		else {
			passThroughSubject.send(completion: .failure(.invalidState))
			return passThroughSubject.eraseToAnyPublisher()
		}
		
		assetWriter.endSession(atSourceTime: lastKnownBufferTimestamp)
		
		self.assetWriter = nil
		self.delegate?.recorderDidFinishRecording(self)
		
		assetWriter.finishWriting {
			switch assetWriter.status {
			case .completed:
				passThroughSubject.send(assetWriter.outputURL)
				passThroughSubject.send(completion: .finished)
			case .failed:
				passThroughSubject.send(completion: .failure(.failedToGenerateVideo))
			case .cancelled:
				passThroughSubject.send(completion: .failure(.cancelled))
			case .unknown, .writing: break
			@unknown default: break
			}
		}
		return passThroughSubject.eraseToAnyPublisher()
	}
	
	func recordVideo(sampleBuffer: CMSampleBuffer) {
		guard
			isRecording,
			let assetWriter = assetWriter,
			let assetWriterInputPixelBufferAdaptor = self.assetWriterInputPixelBufferAdaptor
		else { return }
		
		let currentPresentationTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
		
		if assetWriter.status == .unknown {
			assetWriter.startWriting()
			assetWriter.startSession(atSourceTime: currentPresentationTimestamp)
			self.startingPresentationTimeStamp = currentPresentationTimestamp
			self.previousPresentationTimeStamp = currentPresentationTimestamp
		}
		else if assetWriter.status == .writing, let input = assetWriterVideoInput, input.isReadyForMoreMediaData {
			guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
			
			let previousPresentationTimeStamp = self.previousPresentationTimeStamp
			
			// Frame correction logic. Fixes the bug of video/audio un-synced when switching cameras
			let currentFramePosition =
			(Double(self.frameRate) * Double(currentPresentationTimestamp.value)) / Double(currentPresentationTimestamp.timescale)
			let previousFramePosition = (Double(self.frameRate) * Double(previousPresentationTimeStamp.value)) / Double(previousPresentationTimeStamp.timescale)
			var presentationTimeStamp = currentPresentationTimestamp
			let maxFrameDistance = 1.1
			let frameDistance = currentFramePosition - previousFramePosition
			
			if frameDistance > maxFrameDistance {
				let expectedFramePosition = previousFramePosition + 1.0
				
				//Frame at incorrect position moving from \(currentFramePosition) to \(expectedFramePosition)")
				let newFramePosition = (expectedFramePosition * Double(currentPresentationTimestamp.timescale)) / Double(self.frameRate)
				
				let newPresentationTimeStamp = CMTime(value: CMTimeValue(newFramePosition), timescale: currentPresentationTimestamp.timescale)
				
				presentationTimeStamp = newPresentationTimeStamp
			}
			
			//Write video
			assetWriterInputPixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTimeStamp)
			
			self.previousPresentationTimeStamp = presentationTimeStamp
			
			let startTime = Double(startingPresentationTimeStamp.value) / Double(startingPresentationTimeStamp.timescale)
			let currentTime = Double(currentPresentationTimestamp.value) / Double(currentPresentationTimestamp.timescale)
			let previousTime = Double(previousPresentationTimeStamp.value) / Double(previousPresentationTimeStamp.timescale)
			
			self.frameCount += 1
			
			if (Int(previousTime - startTime) == Int(currentTime - startTime)) == false {
				self.frameCount = 0
			}
			
			if !hasReceivedVideoBuffer {
				delegate?.recorderDidBeginRecording(self)
			}
			
			hasReceivedVideoBuffer = true
			measurement.value = currentTime - startTime
			lastKnownBufferTimestamp = currentPresentationTimestamp
			delegate?.recorderDidUpdateRecordingDuration(self, duration: measurement)
		}
	}
	
	func recordAudio(sampleBuffer: CMSampleBuffer) {
		guard
			hasReceivedVideoBuffer,
			isRecording,
			let assetWriter = assetWriter,
			assetWriter.status == .writing,
			let input = assetWriterAudioInput,
			input.isReadyForMoreMediaData
		else { return }
		input.append(sampleBuffer)
	}
}
