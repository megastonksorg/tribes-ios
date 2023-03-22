//
//  MessageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-05.
//

import SwiftUI

struct MessageView: View {
	let tribeId: Tribe.ID
	let currentTribeMember: TribeMember
	let sender: TribeMember?
	let style: Message.Style
	let message: Message
	let tribe: Tribe
	let isPlaying: Bool
	let isShowingIncomingAuthor: Bool
	let contextMessageAction: (_ messageId: Message.ID) -> ()
	
	@State var playbackProgress: Float = 0
	
	init(
		currentTribeMember: TribeMember,
		message: Message,
		tribe: Tribe,
		isPlaying: Bool,
		isShowingIncomingAuthor: Bool,
		contextMessageAction: @escaping (_ messageId: Message.ID) -> () = { _ in }
	) {
		let sender: TribeMember? = tribe.members[id: message.senderId]
		self.tribeId = tribe.id
		self.currentTribeMember = currentTribeMember
		self.sender = sender
		self.style = {
			if sender?.id == currentTribeMember.id {
				return .outgoing
			} else {
				return .incoming
			}
		}()
		self.message = message
		self.tribe = tribe
		self.isPlaying = isPlaying
		self.isShowingIncomingAuthor = isShowingIncomingAuthor
		self.contextMessageAction = contextMessageAction
	}
	
	var body: some View {
		let bodyModel: MessageBodyModel = MessageBodyModel(
			currentTribeMember: currentTribeMember,
			sender: sender,
			style: style,
			message: message,
			tribe: tribe
		)
		Group {
			switch message.encryptedBody.content {
			case .text:
				MessageTextView(
					model: bodyModel,
					isShowingIncomingAuthor: isShowingIncomingAuthor,
					contextMessageAction: { self.contextMessageAction($0) }
				)
			case .image:
				MessageImageView(model: bodyModel)
			case .video:
				MessageVideoView(model: bodyModel, isPlaying: isPlaying)
					.onPreferenceChange(PlaybackProgressKey.self) {
						self.playbackProgress = $0
					}
			case .systemEvent(let text):
				TextView(text, style: .callout)
					.multilineTextAlignment(.center)
					.padding(.vertical, 6)
			case .imageData:
				EmptyView()
			}
		}
		.id(message.body)
	}
}

struct MessageView_Previews: PreviewProvider {
	static var previews: some View {
		MessageView(
			currentTribeMember: TribeMember.noop1,
			message: Message.noopEncryptedTextChat,
			tribe: Tribe.noop1,
			isPlaying: false,
			isShowingIncomingAuthor: false
		)
	}
}
