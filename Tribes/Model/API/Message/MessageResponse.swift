//
//  MessageResponse.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation

// MARK: - Message
class MessageResponse: Decodable {
	struct Reaction: Decodable {
		let senderWalletAddress: String
		let content: String
	}
	
	let id: String
	let keys: [MessageKeyEncrypted]
	let type: Message.Content.`Type`
	let body: String
	let caption: String?
	let context: MessageResponse?
	let deleted: Bool
	let senderWalletAddress: String
	let reactions: [Reaction]
	let expires: String?
	let tag: Message.Tag
	let timeStamp: String
	
	init(
		id: String,
		keys: [MessageKeyEncrypted],
		type: Message.Content.`Type`,
		body: String,
		caption: String?,
		context: MessageResponse?,
		deleted: Bool,
		senderWalletAddress: String,
		reactions: [Reaction],
		expires: String?,
		tag: Message.Tag,
		timeStamp: String
	) {
		self.id = id
		self.keys = keys
		self.type = type
		self.body = body
		self.caption = caption
		self.context = context
		self.deleted = deleted
		self.senderWalletAddress = senderWalletAddress
		self.reactions = reactions
		self.expires = expires
		self.tag = tag
		self.timeStamp = timeStamp
	}
}
