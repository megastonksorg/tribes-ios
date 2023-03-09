//
//  MessageDraftView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-08.
//

import SwiftUI

struct MessageDraftView: View {
	let messageDraft: MessageDraft
	let isPlaying: Bool
	var body: some View {
		ContentView(content: messageDraft.content, isPlaying: false)
			.ignoresSafeArea()
			.overlay {
				if let caption = messageDraft.caption {
					Text(caption)
						.styleForCaption()
						.offset(y: SizeConstants.teaCaptionOffset)
				}
			}
	}
}

struct MessageDraftView_Previews: PreviewProvider {
	static var previews: some View {
		MessageDraftView(messageDraft: MessageDraft.noop1, isPlaying: false)
	}
}
