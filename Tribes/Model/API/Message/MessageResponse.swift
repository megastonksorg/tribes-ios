//
//  MessageResponse.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation

// MARK: - Message
class MessageResponse: Codable {
	struct Reaction: Codable {
		let senderWalletAddress: String
		let content: String
	}
	
	let id: String
	let keys: [MessageKeyEncrypted]
	let type: String
	let body: String
	let caption: String?
	let context: MessageResponse?
	let senderWalletAddress: String
	let reactions: [Reaction]
	let expires: String?
	let tag, timeStamp: String
	
	init(
		id: String,
		keys: [MessageKeyEncrypted],
		type: String,
		body: String,
		caption: String?,
		context: MessageResponse?,
		senderWalletAddress: String,
		reactions: [Reaction],
		expires: String?,
		tag: String,
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
