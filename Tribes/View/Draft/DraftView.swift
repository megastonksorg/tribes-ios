//
//  DraftView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct DraftView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		if let content = viewModel.content {
			Group {
				GeometryReader { proxy in
					Group {
						ContentView(content: content)
					}
					.frame(size: proxy.size)
				}
				.ignoresSafeArea()
				.overlay(alignment: .topTrailing) {
					Color.gray.opacity(0.02)
						.frame(dimension: 70)
						.onTapGesture {
							viewModel.resetContent()
						}
						.overlay(
							XButton {
								viewModel.resetContent()
							}
						)
				}
			}
		}
	}
}

struct DraftView_Previews: PreviewProvider {
	static var previews: some View {
		DraftView(
			viewModel: .init(
				content: .video(URL(string: "https://kingsleyokeke.blob.core.windows.net/videos/Untitled.mp4")!),
				directRecipient: nil
			)
		)
	}
}
