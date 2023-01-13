//
//  VideoPlayerView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-02.
//

import AVFoundation
import SwiftUI

struct VideoPlayerView: View {
	let thumbnail: UIImage
	let url: URL
	
	@State private var isPlaying = false
	@State private var shouldShowThumbnail = true
	@State private var playbackProgress = Float(0)
	
	init(url: URL) {
		self.thumbnail = {
			let imageGenerator = AVAssetImageGenerator(asset: AVAsset(url: url))
			imageGenerator.appliesPreferredTrackTransform = true
			let cgImage = try? imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
			return cgImage.map(UIImage.init) ?? .init()
		}()
		self.url = url
	}
	
	var body: some View {
		ZStack {
			PlayerView(
				url: url,
				isPlaying: isPlaying,
				isMuted: false,
				shouldShowThumbnail: $shouldShowThumbnail,
				onPlaybackProgressChange: { progress in playbackProgress = progress }
			)
			
			Image(uiImage: thumbnail)
				.resizable()
				.scaledToFit()
				.visible(shouldShowThumbnail)
			
			Color.clear
				.preference(key: PlaybackProgressKey.self, value: playbackProgress)
		}
		.background {
			GeometryReader { proxy in
				Color.clear
					.preference(
						key: PlayerVisibilityKey.self,
						value: proxy.frame(in: .global).maxX > UIScreen.main.bounds.maxX * 0.8
					)
					.onPreferenceChange(PlayerVisibilityKey.self) { isVisible in
						if isVisible {
							self.isPlaying = true
						} else {
							self.isPlaying = false
						}
					}
			}
		}
	}
}

struct VideoPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		VideoPlayerView(
			url: URL(string: "https://kingsleyokeke.blob.core.windows.net/megastonksvideo/MegaStonks.mp4")!
		)
	}
}

fileprivate struct PlayerVisibilityKey: PreferenceKey {
	static var defaultValue: Bool = false
	static func reduce(value: inout Bool, nextValue: () -> Bool) { }
}

fileprivate struct PlaybackProgressKey: PreferenceKey {
	static var defaultValue: Float = 0
	static func reduce(value: inout Float, nextValue: () -> Float) { value = nextValue() }
}
