//
//  Message.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation
import IdentifiedCollections
import UIKit

class Message: Codable, Identifiable {
	struct Reaction: Codable, Identifiable {
		let memberId: TribeMember.ID
		let content: String
		
		var id: TribeMember.ID { memberId }
	}
	
	enum Content: Codable {
		case text(String)
		case image(URL)
		case imageData(Data)
		case video(URL)
		case systemEvent(String)
		
		enum `Type`: String, Codable {
			case text
			case image
			case video
			case systemEvent
		}
		
		var outgoingType: `Type`? {
			switch self {
			case .text: return .text
			case .image, .imageData: return .image
			case .video: return .video
			case .systemEvent: return nil
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
	let decryptionKeys: [MessageKeyEncrypted]
	let encryptedCaption: String?
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
		decryptionKeys: [MessageKeyEncrypted],
		encryptedCaption: String?,
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
		self.decryptionKeys = decryptionKeys
		self.encryptedCaption = encryptedCaption
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
