//
//  MessageVideoView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct MessageVideoView: View {
	let model: MessageBodyModel
	let isMuted: Bool
	let isPlaying: Bool
	
	@State var url: URL? //The local Url of the video to play
	@State var isLoadingVideo: Bool = true
	
	@State var playbackProgress: Float = 0
	
	//Clients
	let cacheClient: CacheClient = CacheClient.shared
	
	var body: some View {
		Group {
			if model.message.isEncrypted && !isLoadingVideo {
				NoContentView(
					isEncrypted: true,
					reloadContent: {
						decryptOrLoadMessageContent()
					}
				)
			} else {
				if isLoadingVideo {
					LoadingIndicator(speed: 0.4)
						.frame(dimension: SizeConstants.loadingIndicatorSize)
				} else if let url = self.url {
					VideoPlayerView(url: url, isMuted: isMuted, isPlaying: isPlaying)
						.onPreferenceChange(PlaybackProgressKey.self) {
							playbackProgress = $0
						}
				} else {
					NoContentView(
						isEncrypted: false,
						reloadContent: {
							decryptOrLoadMessageContent()
						}
					)
				}
			}
		}
		.ignoresSafeArea()
		.overlay(isShown: model.isShowingCaption) {
			if let caption = model.message.body?.caption {
				Text(caption)
					.styleForCaption()
					.offset(y: SizeConstants.teaCaptionOffset)
			}
		}
		.task {
			if url == nil {
				loadVideo()
			}
		}
		.preference(key: PlaybackProgressKey.self, value: playbackProgress)
	}
	
	func loadVideo() {
		Task {
			guard let cacheKey = Cache.getContentCacheKey(encryptedContent: model.message.encryptedBody.content)
			else {
				self.isLoadingVideo = false
				return
			}
			
			let directory = FileManager.default.temporaryDirectory
			let fileName = "\(cacheKey)\(AppConstants.videoFileType)"
			let url = directory.appendingPathComponent(fileName)
			if FileManager.default.fileExists(atPath: url.path()) {
				self.url = url
				self.isLoadingVideo = false
				return
			} else {
				//Load Video Data from Cache if it does not exist in the temp directory
				guard let videoData = await cacheClient.get(key: cacheKey, type: Data.self)
				else {
					self.isLoadingVideo = false
					return
				}
				try? videoData.write(to: url)
				self.url = url
				self.isLoadingVideo = false
			}
		}
	}
	
	func decryptOrLoadMessageContent() {
		Task {
			self.isLoadingVideo = true
			await MessageClient.shared.decryptMessage(message: model.message, tribeId: model.tribe.id, wasReceived: false, force: true)
			try await Task.sleep(for: .seconds(4.0))
			self.isLoadingVideo = false
			loadVideo()
		}
	}
}

struct MessageVideoView_Previews: PreviewProvider {
	static var previews: some View {
		MessageVideoView(
			model: MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				isShowingCaption: true,
				sender: nil,
				style: .incoming,
				message: Message.noopEncryptedVideoTea,
				tribe: Tribe.noop1
			),
			isMuted: false,
			isPlaying: false
		)
	}
}
