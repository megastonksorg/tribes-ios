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
	let thumbnail: UIImage
	
	@State private var shouldShowThumbnail = true
	@State private var playbackProgress = Float(0)
	
	init(url: URL) {
		self.url = url
		self.thumbnail = {
			let imageGenerator = AVAssetImageGenerator(asset: AVAsset(url: url))
			imageGenerator.appliesPreferredTrackTransform = true
			let cgImage = try? imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
			return cgImage.map(UIImage.init) ?? .init()
		}()
	}
	
	public var body: some View {
		ZStack {
			PlayerView(
				url: url,
				isPlaying: true,
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
	}
}

struct VideoPlayerView_Previews: PreviewProvider {
	static var previews: some View {
		VideoPlayerView(
			url: URL(string: "https://kingsleyokeke.blob.core.windows.net/megastonksvideo/MegaStonks.mp4")!
		)
	}
}

struct PlaybackProgressKey: PreferenceKey {
	static public var defaultValue: Float = 0
	static public func reduce(value: inout Float, nextValue: () -> Float) { value = nextValue() }
}
