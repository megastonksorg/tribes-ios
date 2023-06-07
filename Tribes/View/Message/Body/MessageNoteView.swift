//
//  MessageNoteView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-06-06.
//

import SwiftUI

struct MessageNoteView: View {
	let model: MessageBodyModel
	
	@State var isDecryptingMessage: Bool = false
	
	var body: some View {
		Group {
			if model.message.isEncrypted && !isDecryptingMessage {
				NoContentView(
					isEncrypted: true,
					reloadContent: {
						decryptOrLoadMessageContent()
					}
				)
			} else {
				if isDecryptingMessage {
					LoadingIndicator(speed: 0.4)
						.frame(dimension: SizeConstants.loadingIndicatorSize)
				} else {
					if case .note(let url) = model.message.body?.content {
						if let caption = model.message.body?.caption {
							NoteContentView(url: url, content: caption)
						}
					}
				}
			}
		}
		.ignoresSafeArea()
		.task {
			if model.message.isEncrypted {
				decryptOrLoadMessageContent()
			}
		}
	}
	
	func decryptOrLoadMessageContent() {
		Task {
			self.isDecryptingMessage = true
			await MessageClient.shared.decryptMessage(message: model.message, tribeId: model.tribe.id, wasReceived: false, force: true)
			try await Task.sleep(for: .seconds(4.0))
			self.isDecryptingMessage = false
		}
	}
}

struct MessageNoteView_Previews: PreviewProvider {
	static var previews: some View {
		MessageNoteView(
			model: MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				isShowingCaption: false,
				sender: nil,
				style: .outgoing,
				message: Message.noopDecryptedNote,
				tribe: Tribe.noop1
			)
		)
	}
}
