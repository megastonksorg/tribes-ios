//
//  VideoPlayerView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-02.
//

import SwiftUI

struct VideoPlayerView: View {
	let thumbnail: UIImage
	let url: URL
	let isPlaying: Bool
	let isMuted: Bool
	
	@State private var shouldShowThumbnail = true
	@State private var playbackProgress = Float(0)
	
	public init(
		thumbnail: UIImage,
		url: URL,
		isPlaying: Bool,
		isMuted: Bool
	) {
		self.thumbnail = thumbnail
		self.url = url
		self.isPlaying = isPlaying
		self.isMuted = isMuted
	}
	
	public var body: some View {
		ZStack {
			PlayerView(
				url: url,
				isPlaying: isPlaying,
				isMuted: isMuted,
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
	}
}

struct VideoPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		VideoPlayerView(
			thumbnail: UIImage(),
			url: URL(string: "https://kingsleyokeke.blob.core.windows.net/megastonksvideo/MegaStonks.mp4")!,
			isPlaying: true,
			isMuted: false
		)
		.ignoresSafeArea()
	}
}

struct PlaybackProgressKey: PreferenceKey {
	static public var defaultValue: Float = 0
	static public func reduce(value: inout Float, nextValue: () -> Float) { value = nextValue() }
}
