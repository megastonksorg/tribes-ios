//
//  MessageVideoView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct MessageVideoView: View {
	let model: MessageBodyModel
	let isPlaying: Bool
	
	@State var url: URL? //The local Url of the video to play
	@State var isLoadingVideo: Bool = true
	
	//Clients
	let cacheClient: CacheClient = CacheClient.shared
	
	var body: some View {
		Group {
			if model.message.isEncrypted {
				NoContentView(isEncrypted: true)
			} else {
				if isLoadingVideo {
					
				} else if let url = self.url {
					VideoPlayerView(url: url, isPlaying: isPlaying)
						.overlay {
							if let caption = model.message.body?.caption {
								Text(caption)
									.styleForCaption()
									.offset(y: SizeConstants.teaCaptionOffset)
							}
						}
				} else {
					NoContentView(isEncrypted: false)
				}
			}
		}
		.ignoresSafeArea()
		.task {
			if url == nil {
				loadVideo()
			}
		}
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
}

struct MessageVideoView_Previews: PreviewProvider {
	static var previews: some View {
		MessageVideoView(
			model: MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				sender: nil,
				style: .incoming,
				message: Message.noopEncryptedVideoTea
			),
			isPlaying: false
		)
	}
}
