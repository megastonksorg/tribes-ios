//
//  MessageResponse.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation

// MARK: - Message
class MessageResponse: Decodable {
	let id: String
	let keys: [MessageKeyEncrypted]
	let type: Message.Body.Content.`Type`
	let body: String
	let caption: String?
	let context: String?
	let senderWalletAddress: String
	let reactions: [Message.Reaction]?
	let expires: String?
	let tag: Message.Tag
	let timeStamp: String
	
	init(
		id: String,
		keys: [MessageKeyEncrypted],
		type: Message.Body.Content.`Type`,
		body: String,
		caption: String?,
		context: String?,
		senderWalletAddress: String,
		reactions: [Message.Reaction]?,
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
		self.senderWalletAddress = senderWalletAddress
		self.reactions = reactions
		self.expires = expires
		self.tag = tag
		self.timeStamp = timeStamp
	}
}
