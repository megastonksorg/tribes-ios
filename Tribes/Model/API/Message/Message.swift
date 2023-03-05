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
	
	enum Tag: String, Codable {
		case chat
		case tea
	}
	
	struct Body: Codable {
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
		let content: Content
		let caption: String?
	}
	
	let id: String
	let context: Message?
	let decryptionKeys: [MessageKeyEncrypted]
	let encryptedBody: Body
	let senderId: TribeMember.ID
	let reactions: [Reaction]
	let tag: Tag
	let expires: Date?
	let timeStamp: Date
	
	var body: Body?
	
	var isEncrypted: Bool {
		 body == nil
	}
	
	init(
		id: String,
		context: Message?,
		decryptionKeys: [MessageKeyEncrypted],
		encryptedBody: Body,
		senderId: TribeMember.ID,
		reactions: [Reaction],
		tag: Tag,
		expires: Date?,
		timeStamp: Date
	) {
		self.id = id
		self.context = context
		self.decryptionKeys = decryptionKeys
		self.encryptedBody = encryptedBody
		self.senderId = senderId
		self.reactions = reactions
		self.tag = tag
		self.expires = expires
		self.timeStamp = timeStamp
	}
}

struct TribeMessages: Identifiable {
	let tribeId: Tribe.ID
	var messages: IdentifiedArrayOf<Message>
	var drafts: IdentifiedArrayOf<MessageDraft>
	
	var lastReadChat: Date?
	var lastReadTea: Date?
	
	var id: Tribe.ID { tribeId }
	
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
	let content: Message.Body.Content
	let contextId: Message.ID
	let caption: String?
	let tag: Message.Tag
	let tribeId: Tribe.ID
}
