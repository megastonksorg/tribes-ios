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
	
	@State var playbackProgress: Float = 0
	
	var body: some View {
		ContentView(content: draft.content, isPlaying: isPlaying)
			.onPreferenceChange(PlaybackProgressKey.self) {
				playbackProgress = $0
			}
			.ignoresSafeArea()
			.overlay {
				if let caption = draft.caption {
					Text(caption)
						.styleForCaption()
						.offset(y: SizeConstants.teaCaptionOffset)
				}
			}
			.preference(key: PlaybackProgressKey.self, value: playbackProgress)
	}
}

struct MessageDraftView_Previews: PreviewProvider {
	static var previews: some View {
		MessageDraftView(draft: MessageDraft.noop1, isPlaying: false)
	}
}
