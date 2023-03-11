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
		if draft.content.outgoingType == .text {
			HStack {
				Spacer()
				Button(action: { }) {
					HStack {
						Text("Retry")
						Image(systemName: "arrow.counterclockwise.circle.fill")
					}
					.font(Font.app.body)
					.foregroundColor(Color.white)
					.padding()
					.dropShadow()
					.dropShadow()
				}
				.opacity(draft.status == .failedToUpload ? 1.0 : 0.0)
				ContentView(content: draft.content, isPlaying: false)
					.opacity(0.6)
			}
		} else {
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
}

struct MessageDraftView_Previews: PreviewProvider {
	static var previews: some View {
		MessageDraftView(draft: MessageDraft.noop2, isPlaying: false)
	}
}
