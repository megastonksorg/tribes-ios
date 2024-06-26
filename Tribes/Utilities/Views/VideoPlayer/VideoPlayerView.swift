//
//  VideoPlayerView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-02.
//

import AVFoundation
import SwiftUI

struct VideoPlayerView: View {
	let url: URL
	let isMuted: Bool
	let isPlaying: Bool
	
	@State private var shouldShowThumbnail = true
	@State private var playbackProgress = Float(0)
	@State private var thumbnail: UIImage? = nil
	
	//Clients
	let cacheClient: CacheClient = CacheClient.shared
	
	init(url: URL, isMuted: Bool, isPlaying: Bool) {
		self.url = url
		self.isMuted = isMuted
		self.isPlaying = isPlaying
	}
	
	var body: some View {
		ZStack {
			Group {
				if let thumbnail = self.thumbnail {
					Image(uiImage: thumbnail)
						.resizable()
						.scaledToFill()
				} else {
					Color.app.primary
				}
			}
			.ignoresSafeArea()
			.overlay(isShown: thumbnail == nil && !isPlaying) {
				LoadingIndicator(speed: 0.4)
					.frame(dimension: SizeConstants.loadingIndicatorSize)
			}
			PlayerView(
				url: url,
				isPlaying: isPlaying,
				isMuted: isMuted,
				shouldShowThumbnail: $shouldShowThumbnail,
				onPlaybackProgressChange: { progress in playbackProgress = progress }
			)
			Color.clear
				.preference(key: PlaybackProgressKey.self, value: playbackProgress)
		}
		.ignoresSafeArea()
		.onAppear { loadThumbnail() }
	}
	
	func loadThumbnail() {
		Task {
			guard thumbnail == nil else { return }
			if let imageInCache = await cacheClient.getImage(url: self.url) {
				self.thumbnail = imageInCache
			} else {
				let imageGenerator = AVAssetImageGenerator(asset: AVAsset(url: url))
				imageGenerator.appliesPreferredTrackTransform = true
				let cgImage = try? imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
				let image = cgImage.map(UIImage.init) ?? .init()
				self.thumbnail = image
				await self.cacheClient.setImage(url: self.url, image: image)
			}
		}
	}
}

struct VideoPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		VideoPlayerView(
			url: URL(string: "https://kingsleyokeke.blob.core.windows.net/megastonksvideo/MegaStonks.mp4")!,
			isMuted: false,
			isPlaying: false
		)
	}
}

struct PlaybackProgressKey: PreferenceKey {
	static var defaultValue: Float = 0
	static func reduce(value: inout Float, nextValue: () -> Float) { value = nextValue() }
}
