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

public protocol RecorderDelegate: AnyObject {
	/// Fires when we receive the first valid video buffer
	func recorderDidBeginRecording(_ recorder: Recorder)
	
	/// Fires each time we update with a valid video buffer
	func recorderDidUpdateRecordingDuration(_ recorder: Recorder, duration: Measurement<UnitDuration>)
	
	/// Fires when we finish recording
	func recorderDidFinishRecording(_ recorder: Recorder)
}

public final class Recorder {
	
	// MARK: - Properties
	
	weak var delegate: RecorderDelegate?
	
	private(set) var isRecording = false
	private(set) var measurement: Measurement<UnitDuration> = .init(
		value: 0,
		unit: .seconds
	)
	
	private var assetWriter: AVAssetWriter?
	private var assetWriterVideoInput: AVAssetWriterInput?
	private var assetWriterAudioInput: AVAssetWriterInput?
	
	private var videoSettings: [String: Any]
	private var audioSettings: [String: Any]?
	private var videoTransform: CGAffineTransform
	
	private var startTime = Double(0)
	private var hasReceivedVideoBuffer = false
	
	private var lastKnownBufferTimestamp: CMTime?
	
	// MARK: - Lifecycle
	init(
		audioSettings: [String: Any]?,
		videoSettings: [String: Any],
		videoTransform: CGAffineTransform
	) {
		self.audioSettings = audioSettings
		self.videoSettings = videoSettings
		self.videoTransform = videoTransform
	}
	
	// MARK: - Recording
	func startRecording(
		fileURL: URL,
		fileType: AVFileType,
		size: CGSize
	) {
		guard let writer = try? AVAssetWriter(url: fileURL, fileType: fileType) else { return }
		writer.shouldOptimizeForNetworkUse = true
		
		audioSettings?[AVFormatIDKey] = kAudioFormatMPEG4AAC
		audioSettings?[AVNumberOfChannelsKey] = 2
		audioSettings?[AVSampleRateKey] = 44100
		
		if let audioSettings = audioSettings {
			let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
			audioInput.expectsMediaDataInRealTime = true
			writer.add(audioInput)
			assetWriterAudioInput = audioInput
		}
		
		videoSettings[AVVideoCodecKey] = AVVideoCodecType.hevc
		videoSettings[AVVideoWidthKey] = size.width
		videoSettings[AVVideoHeightKey] = size.height
		videoSettings[AVVideoScalingModeKey] = AVVideoScalingModeResizeAspectFill
		
		/// Beginning of patch for older devices.
		/// On older devices such as the iPhone 7 Plus the generated video settings from the system give us defaults outside of the HEVC encoder. We receive an H264 entropy key by default which we remove here and replace the profile level key with one that the HEVC encoder expects. Without the change and removal of the property below the app crashes with uncaught exceptions.
		var compressionProperties = videoSettings[AVVideoCompressionPropertiesKey] as? [String: Any]
		compressionProperties?[AVVideoProfileLevelKey] = kVTProfileLevel_HEVC_Main_AutoLevel
		compressionProperties?[AVVideoH264EntropyModeKey] = nil
		if let compressionProperties { videoSettings[AVVideoCompressionPropertiesKey] = compressionProperties }
		/// End of patch for older devices.
		
		let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
		videoInput.expectsMediaDataInRealTime = true
		videoInput.transform = videoTransform
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

