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
	let reactions: [TribeMember.ID : String]
	let sender: TribeMember
	let style: Style
	let timeStamp: Date
	
	init(
		id: String,
		content: Content,
		context: ChatMessage? = nil,
		reactions: [TribeMember.ID : String],
		sender: TribeMember,
		style: Style,
		timeStamp: Date
	) {
		self.id = id
		self.content = content
		self.context = context
		self.reactions = reactions
		self.sender = sender
		self.style = style
		self.timeStamp = timeStamp
	}
}

extension ChatMessage {
	static let noop1: ChatMessage = ChatMessage(
		id: UUID().uuidString,
		content: .text("Stop there. Please change account info when you get a chance"),
		reactions: [:],
		sender: TribeMember.noop1,
		style: .incoming,
		timeStamp: Calendar.current.date(byAdding: .month, value: -2, to: Date())!
	)
	static let noop2: ChatMessage = ChatMessage(
		id: UUID().uuidString,
		content: .text("Where are we going for dinner? 🍽️ 🍛 Are you all coming?!"),
		reactions: [:],
		sender: TribeMember.noop2,
		style: .incoming,
		timeStamp: Calendar.current.date(byAdding: .minute, value: -10, to: Date())!
	)
	static let noop3: ChatMessage = ChatMessage(
		id: UUID().uuidString,
		content: .text("Hey there, are you really sure you would like to go through with this?"),
		reactions: [:],
		sender: TribeMember.noop3,
		style: .incoming,
		timeStamp: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!
	)
	static let noop4: ChatMessage = ChatMessage(
		id: UUID().uuidString,
		content: .text("Hahaha 😂😂 Well, well, isn't that a crazy coincidence?"),
		reactions: [:],
		sender: TribeMember.noop4,
		style: .outgoing,
		timeStamp: Date.now
	)
}
