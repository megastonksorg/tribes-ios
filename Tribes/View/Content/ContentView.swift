//
//  ContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-01.
//

import SwiftUI

struct ContentView: View {
	let content: Message.Content
	
	var body: some View {
		switch content {
		case .text(let textString):
			Text(textString)
		case .image(let url):
			let cornerRadius: CGFloat = 10
			CachedImage(
				url: url,
				content: { uiImage in
					Image(uiImage: uiImage)
						.resizable()
						.scaledToFill()
						.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
				}, placeHolder: {
					RoundedRectangle(cornerRadius: cornerRadius)
						.fill(Color.gray.opacity(0.2))
						.overlay(
							LoadingIndicator(speed: 0.4)
								.frame(dimension: SizeConstants.loadingIndicatorSize)
						)
				}
			)
		case .video(let url):
			VideoPlayerView(url: url)
		case .systemEvent(let eventString):
			Text(eventString)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(content: .video(URL(string: "https://kingsleyokeke.blob.core.windows.net/videos/Untitled.mp4")!))
	}
}
