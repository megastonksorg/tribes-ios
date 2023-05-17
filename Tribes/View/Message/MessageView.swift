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
	let isMuted: Bool
	let isPlaying: Bool
	let isShowingCaption: Bool
	let isShowingIncomingAuthor: Bool
	let contextMessageAction: (_ messageId: Message.ID) -> ()
	
	@State var playbackProgress: Float = 0
	
	init(
		currentTribeMember: TribeMember,
		message: Message,
		tribe: Tribe,
		isMuted: Bool,
		isPlaying: Bool,
		isShowingCaption: Bool,
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
		self.isMuted = isMuted
		self.isPlaying = isPlaying
		self.isShowingCaption = isShowingCaption
		self.isShowingIncomingAuthor = isShowingIncomingAuthor
		self.contextMessageAction = contextMessageAction
	}
	
	var body: some View {
		let bodyModel: MessageBodyModel = MessageBodyModel(
			currentTribeMember: currentTribeMember,
			isShowingCaption: isShowingCaption,
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
				MessageVideoView(model: bodyModel, isMuted: isMuted, isPlaying: isPlaying)
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
		.onAppear {
			if bodyModel.message.isEncrypted {
				MessageClient.shared.decryptMessage(message: bodyModel.message, tribeId: tribeId, wasReceived: false, force: true)
			}
		}
	}
}

struct MessageView_Previews: PreviewProvider {
	static var previews: some View {
		MessageView(
			currentTribeMember: TribeMember.noop1,
			message: Message.noopEncryptedTextChat,
			tribe: Tribe.noop1,
			isMuted: true,
			isPlaying: false,
			isShowingCaption: false,
			isShowingIncomingAuthor: false
		)
	}
}
