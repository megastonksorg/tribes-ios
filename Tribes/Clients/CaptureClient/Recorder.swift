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
	
	private var startTime = Double(0)
	private var hasReceivedVideoBuffer = false
	
	private var lastKnownBufferTimestamp: CMTime?
	
	// MARK: - Recording
	func startVideoRecording(videoSettings: [String :Any]?) {
		let fileName = UUID().uuidString + ".mp4"
		let fileUrl = FileManager.default.temporaryDirectory.appending(path: fileName)
		
		guard let writer = try? AVAssetWriter(outputURL: fileUrl, fileType: .mp4) else { return }
		
		writer.shouldOptimizeForNetworkUse = true
		
		let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
		videoInput.expectsMediaDataInRealTime = true
		
		writer.add(videoInput)
		assetWriterVideoInput = videoInput
		
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
			let assetWriter = assetWriter
		else { return }
		
		if assetWriter.status == .unknown, let input = assetWriterVideoInput {
			assetWriter.startWriting()
			let startTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
			assetWriter.startSession(atSourceTime: startTimeStamp)
			startTime = Double(startTimeStamp.value) / Double(startTimeStamp.timescale)
			input.append(sampleBuffer)
		}
		else if assetWriter.status == .writing, let input = assetWriterVideoInput, input.isReadyForMoreMediaData {
			input.append(sampleBuffer)
			if hasReceivedVideoBuffer == false { delegate?.recorderDidBeginRecording(self) }
			hasReceivedVideoBuffer = true
			let currentTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
			let currentTime = Double(currentTimeStamp.value) / Double(currentTimeStamp.timescale)
			measurement.value = currentTime - startTime
			lastKnownBufferTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
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
