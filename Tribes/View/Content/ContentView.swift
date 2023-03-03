//
//  ContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-01.
//

import SwiftUI

struct ContentView: View {
	let imageCornerRadius: CGFloat = 10
	
	let content: Message.Content
	var body: some View {
		switch content {
		case .text(let textString):
			Text(textString)
		case .image(let url):
			CachedImage(
				url: url,
				content: { uiImage in
					imageView(uiImage: uiImage)
				}, placeHolder: {
					RoundedRectangle(cornerRadius: imageCornerRadius)
						.fill(Color.gray.opacity(0.2))
						.overlay(
							LoadingIndicator(speed: 0.4)
								.frame(dimension: SizeConstants.loadingIndicatorSize)
						)
				}
			)
		case .imageData(let imageData):
			imageView(uiImage: UIImage(data: imageData) ?? UIImage())
		case .video(let url):
			VideoPlayerView(url: url)
		case .systemEvent(let eventString):
			Text(eventString)
		}
	}
	
	@ViewBuilder
	func imageView(uiImage: UIImage) -> some View {
		Image(uiImage: uiImage)
			.resizable()
			.scaledToFill()
			.clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(content: .video(URL(string: "https://kingsleyokeke.blob.core.windows.net/videos/Untitled.mp4")!))
	}
}
