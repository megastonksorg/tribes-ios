//
//  Message.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation
import IdentifiedCollections
import UIKit

class Message: Identifiable {
	struct Reaction: Codable, Identifiable {
		let memberId: TribeMember.ID
		let content: String
		
		var id: TribeMember.ID { memberId }
	}
	
	enum Content {
		case text(String)
		case image(URL)
		case uiImage(UIImage)
		case video(URL)
		case systemEvent(String)
		
		var outgoingType: String {
			switch self {
			case .text: return "text"
			case .image, .uiImage: return "image"
			case .video: return "video"
			case .systemEvent: return ""
			}
		}
	}
	
	enum Tag: String, Codable {
		case chat
		case tea
	}
	
	let id: String
	let content: Content?
	let caption: String?
	let context: Message?
	let encryptedContent: Content
	let senderId: TribeMember.ID
	let reactions: [Reaction]
	var isEncrypted: Bool
	let expires: Date?
	let timeStamp: Date
	
	init(
		id: String,
		content: Content?,
		caption: String?,
		context: Message?,
		encryptedContent: Content,
		senderId: TribeMember.ID,
		reactions: [Reaction],
		isEncrypted: Bool,
		expires: Date?,
		timeStamp: Date
	) {
		self.id = id
		self.content = content
		self.caption = caption
		self.context = context
		self.encryptedContent = encryptedContent
		self.senderId = senderId
		self.reactions = reactions
		self.isEncrypted = isEncrypted
		self.expires = expires
		self.timeStamp = timeStamp
	}
}

struct TribeAndMessages: Identifiable {
	let tribe: Tribe
	var chat: IdentifiedArrayOf<Message>
	var tea: IdentifiedArrayOf<Message>
	var chatDrafts: IdentifiedArrayOf<MessageDraft>
	var teaDrafts: IdentifiedArrayOf<MessageDraft>
	var lastReadChat: Date?
	var lastReadTea: Date?
	
	var id: Tribe.ID { tribe.id }
}

struct MessageDraft: Identifiable {
	let id: UUID
	let content: Message.Content
	let contextId: Message.ID
	let caption: String?
	let tag: Message.Tag
	let tribeId: Tribe.ID
}
