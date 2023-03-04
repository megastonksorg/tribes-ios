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
	let tag: Tag
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
		tag: Tag,
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
		self.tag = tag
		self.isEncrypted = isEncrypted
		self.expires = expires
		self.timeStamp = timeStamp
	}
}

struct TribeAndMessages: Identifiable {
	let tribe: Tribe
	var messages: IdentifiedArrayOf<Message>
	var drafts: IdentifiedArrayOf<MessageDraft>
	
	var lastReadChat: Date?
	var lastReadTea: Date?
	
	var id: Tribe.ID { tribe.id }
	
	var chat: IdentifiedArrayOf<Message> {
		messages.filter { $0.tag == .chat }
	}
	
	var tea: IdentifiedArrayOf<Message> {
		messages.filter { $0.tag == .tea }
	}
	
	var chatDrafts: IdentifiedArrayOf<MessageDraft> {
		drafts.filter { $0.tag == .chat }
	}
	
	var teaDrafts: IdentifiedArrayOf<MessageDraft> {
		drafts.filter { $0.tag == .tea }
	}
}

struct MessageDraft: Identifiable {
	let id: UUID
	let content: Message.Content
	let contextId: Message.ID
	let caption: String?
	let tag: Message.Tag
	let tribeId: Tribe.ID
}
