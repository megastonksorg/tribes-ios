//
//  Message.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation

class Message: Identifiable {
	struct Reaction: Codable, Identifiable {
		let memberId: TribeMember.ID
		let content: String
		
		var id: TribeMember.ID { memberId }
	}
	
	enum Content {
		case text(String)
		case image(URL)
		case video(URL)
		case systemEvent(String)
	}
	
	let id: String
	var content: Content
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
		content: Content,
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
