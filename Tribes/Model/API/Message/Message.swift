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
	let chat: IdentifiedArrayOf<Message>
	let tea: IdentifiedArrayOf<Message>
	let pendingTea: IdentifiedArrayOf<Message>
	let lastReadChat: Date?
	let lastReadTea: Date?
	
	var id: Tribe.ID { tribe.id }
}
