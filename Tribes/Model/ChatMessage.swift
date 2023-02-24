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
	let context: ChatMessage
	let sender: TribeMember
	let style: Style
	
	init(id: String, content: Content, context: ChatMessage, sender: TribeMember, style: Style) {
		self.id = id
		self.content = content
		self.context = context
		self.sender = sender
		self.style = style
	}
}
