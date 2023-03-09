//
//  MessageDraftView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-08.
//

import SwiftUI

struct MessageDraftView: View {
	let messageDraft: MessageDraft
	var body: some View {
		ContentView(content: messageDraft.content)
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
		MessageDraftView(messageDraft: MessageDraft.noop1)
	}
}
