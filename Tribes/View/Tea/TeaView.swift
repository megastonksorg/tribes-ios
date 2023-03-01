//
//  TeaView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct TeaView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: TeaView.ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		GeometryReader { proxy in
			Group {
				switch viewModel.content {
				case .image(let image):
					Image(uiImage: image)
						.resizable()
						.scaledToFill()
				case .video(let url):
					VideoPlayerView(url: url)
				}
			}
			.frame(size: proxy.size)
		}
		.ignoresSafeArea()
	}
}

struct TeaView_Previews: PreviewProvider {
	static var previews: some View {
		TeaView(viewModel: .init(content: .image(UIImage())))
	}
}
