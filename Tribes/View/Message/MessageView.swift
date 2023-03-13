//
//  MessageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-05.
//

import SwiftUI

struct MessageView: View {
	let currentTribeMember: TribeMember
	let sender: TribeMember?
	let style: Message.Style
	let message: Message
	let isPlaying: Bool
	let isShowingUserInfo: Bool
	
	@State var playbackProgress: Float = 0
	
	init(
		currentTribeMember: TribeMember,
		message: Message,
		tribe: Tribe,
		isPlaying: Bool,
		isShowingUserInfo: Bool
	) {
		let sender: TribeMember? = tribe.members[id: message.senderId]
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
		self.isPlaying = isPlaying
		self.isShowingUserInfo = isShowingUserInfo
	}
	
	var body: some View {
		let bodyModel: MessageBodyModel = MessageBodyModel(
			currentTribeMember: currentTribeMember,
			sender: sender,
			style: style,
			message: message
		)
		Group {
			switch message.encryptedBody.content {
			case .text:
				MessageTextView(model: bodyModel, isShowingUserInfo: isShowingUserInfo)
			case .image:
				MessageImageView(model: bodyModel)
			case .video:
				MessageVideoView(model: bodyModel, isPlaying: isPlaying)
					.onPreferenceChange(PlaybackProgressKey.self) {
						self.playbackProgress = $0
					}
			case .systemEvent(let text):
				TextView(text, style: .callout)
			case .imageData:
				EmptyView()
			}
		}
		.id(message.body)
		.onAppear {
			if message.isEncrypted {
				MessageClient.shared.decryptMessage(message: message)
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
			isPlaying: false,
			isShowingUserInfo: false
		)
	}
}
