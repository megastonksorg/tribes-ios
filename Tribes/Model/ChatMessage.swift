//
//  ChatMessage.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-23.
//

import Foundation

struct ChatMessage {
	enum Content {
		case text(String?)
		case videoWithCaption(_ videoUrl: URL?, _ caption: String?)
		case imageWithCaption(_ imageUrl: URL?, _ caption: String?)
	}
	
	enum Style {
		case incoming
		case outgoing
	}
	
	let content: Content
	let style: Style
}
