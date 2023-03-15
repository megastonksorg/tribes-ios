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
	let retryDraft: (MessageDraft) -> Void
	let deleteDraft: (MessageDraft) -> Void
	
	@State var playbackProgress: Float = 0
	
	var body: some View {
		if draft.content.outgoingType == .text {
			HStack(spacing: 0) {
				let padding: CGFloat = 8
				let isShowingRetryButton: Bool = {
					return draft.status == .failedToUpload || draft.isStuckUploading
				}()
				if isShowingRetryButton {
					HStack(spacing: 0) {
						Button(action: { deleteDraft(draft) }) {
							Image(systemName: "trash.circle.fill")
								.padding(padding)
								.dropShadow()
								.dropShadow()
						}
						Button(action: { retryDraft(draft) }) {
							Image(systemName: "arrow.counterclockwise.circle.fill")
								.foregroundColor(Color.white)
								.padding(padding)
								.dropShadow()
								.dropShadow()
						}
					}
					.font(Font.app.title)
					.foregroundColor(Color.white)
				}
				Spacer(minLength: 0)
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
		MessageDraftView(
			draft: MessageDraft.noop2,
			isPlaying: false,
			retryDraft: { _ in },
			deleteDraft: { _ in }
		)
	}
}
