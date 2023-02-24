//
//  ChatMessage.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-23.
//

import Foundation

class ChatMessage: Identifiable {
	enum Content {
		case text(String?)
		case videoWithCaption(_ videoUrl: URL?, _ caption: String?)
		case imageWithCaption(_ imageUrl: URL?, _ caption: String?)
	}
	
	enum Style {
		case incoming
		case outgoing
	}
	
	let id: String
	let content: Content
	let context: ChatMessage?
	let sender: TribeMember
	let style: Style
	
	init(id: String, content: Content, context: ChatMessage? = nil, sender: TribeMember, style: Style) {
		self.id = id
		self.content = content
		self.context = context
		self.sender = sender
		self.style = style
	}
}

extension ChatMessage {
	static let noop1: ChatMessage = ChatMessage(
		id: UUID().uuidString,
		content: .text("Stop there. Please change account info when you get a chance"),
		sender: TribeMember.noop1,
		style: .incoming
	)
	static let noop2: ChatMessage = ChatMessage(
		id: UUID().uuidString,
		content: .text("Where are we going for dinner? 🍽️ 🍛 Are you all coming?!"),
		sender: TribeMember.noop2,
		style: .incoming
	)
	static let noop3: ChatMessage = ChatMessage(
		id: UUID().uuidString,
		content: .text("Hey there, are you really sure you would like to go through with this?"),
		sender: TribeMember.noop3,
		style: .incoming
	)
	static let noop4: ChatMessage = ChatMessage(
		id: UUID().uuidString,
		content: .text("Hahaha 😂😂 Well, well, isn't that a crazy coincidence?"),
		sender: TribeMember.noop4,
		style: .outgoing
	)
}
