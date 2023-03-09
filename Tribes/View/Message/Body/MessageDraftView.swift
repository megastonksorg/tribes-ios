//
//  MessageDraftView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-08.
//

import SwiftUI

struct MessageDraftView: View {
	let draft: MessageDraft
	let isPlaying: Bool
	var body: some View {
		ContentView(content: draft.content, isPlaying: isPlaying)
			.ignoresSafeArea()
			.overlay {
				if let caption = draft.caption {
					Text(caption)
						.styleForCaption()
						.offset(y: SizeConstants.teaCaptionOffset)
				}
			}
			.overlay {
				switch draft.status {
				case .uploading:
					EmptyView()
				case .failedToUpload:
					VStack {
						Text("Something went wrong")
							.font(Font.app.subHeader)
							.foregroundColor(Color.gray)
							.dropShadow()
							.dropShadow()
						Button(action: { MessageClient.shared.postMessage(draft: draft) }) {
							HStack {
								Text("Retry")
								Image(systemName: "arrow.counterclockwise.circle.fill")
							}
							.font(Font.app.title)
							.foregroundColor(Color.white)
							.padding()
							.dropShadow()
						}
					}
				}
			}
	}
}

struct MessageDraftView_Previews: PreviewProvider {
	static var previews: some View {
		MessageDraftView(draft: MessageDraft.noop1, isPlaying: false)
	}
}
