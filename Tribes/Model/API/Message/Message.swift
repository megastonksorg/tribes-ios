//
//  Message.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation
import IdentifiedCollections
import UIKit

struct Message: Codable, Identifiable {
	enum Style {
		case incoming
		case outgoing
	}
	
	enum Tag: String, Codable {
		case chat
		case tea
	}
	
	struct Body: Codable, Hashable {
		enum Content: Codable, Hashable {
			case text(String)
			case image(URL)
			case imageData(Data)
			case video(URL)
			case systemEvent(String)
			
			enum `Type`: String, Codable, Hashable {
				case text
				case image
				case video
				case systemEvent
			}
			
			var type: `Type` {
				switch self {
				case .text: return .text
				case .image, .imageData: return .image
				case .video: return .video
				case .systemEvent: return .systemEvent
				}
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
	
	struct Reaction: Codable {
		let senderWalletAddress: String
		let content: String
	}
	
	let id: String
	let context: Message.ID?
	let decryptionKeys: [MessageKeyEncrypted]
	let encryptedBody: Body
	let senderId: TribeMember.ID
	let tag: Tag
	let expires: Date?
	let timeStamp: Date
	
	var reactions: [Message.Reaction]?
	var body: Body?
	
	var isEncrypted: Bool {
		 body == nil
	}
	
	init(
		id: String,
		context: Message.ID?,
		decryptionKeys: [MessageKeyEncrypted],
		encryptedBody: Body,
		senderId: TribeMember.ID,
		reactions: [Reaction]?,
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

extension Message {
	@MainActor var isRead: Bool {
		return MessageClient.shared.readMessage.contains(self.id)
	}
}

extension Message {
	//Encrypted
	static let noopEncryptedTextChat: Message = Message(
		id: "A",
		context: nil,
		decryptionKeys: [],
		encryptedBody: Body(content: .text("ENCRYPTED TEXT"), caption: nil),
		senderId: UUID().uuidString,
		reactions: [],
		tag: .chat,
		expires: nil,
		timeStamp: Date.now
	)
	static let noopEncryptedImageChat: Message = Message(
		id: "B",
		context: nil,
		decryptionKeys: [],
		encryptedBody: Body(content: .image(URL(string: "https://invalidContent.com")!), caption: nil),
		senderId: UUID().uuidString,
		reactions: [],
		tag: .chat,
		expires: nil,
		timeStamp: Date.now
	)
	static let noopEncryptedVideoChat: Message = Message(
		id: "C",
		context: nil,
		decryptionKeys: [],
		encryptedBody: Body(content: .video(URL(string: "https://invalidContent.com")!), caption: nil),
		senderId: UUID().uuidString,
		reactions: [],
		tag: .chat,
		expires: nil,
		timeStamp: Date.now
	)
	static let noopEncryptedImageTea: Message = Message(
		id: "D",
		context: nil,
		decryptionKeys: [],
		encryptedBody: Body(content: .image(URL(string: "https://invalidContent.com")!), caption: nil),
		senderId: UUID().uuidString,
		reactions: [],
		tag: .chat,
		expires: nil,
		timeStamp: Date.now
	)
	static let noopEncryptedVideoTea: Message = Message(
		id: "E",
		context: nil,
		decryptionKeys: [],
		encryptedBody: Body(content: .video(URL(string: "https://invalidContent.com")!), caption: nil),
		senderId: UUID().uuidString,
		reactions: [],
		tag: .chat,
		expires: nil,
		timeStamp: Date.now
	)
	
	//Decrypted
	static let noopDecryptedTextChat: Message = {
		var message = Message(
			id: "F",
			context: nil,
			decryptionKeys: [],
			encryptedBody: Body(content: .text("ENCRYPTED TEXT"), caption: nil),
			senderId: UUID().uuidString,
			reactions: [],
			tag: .chat,
			expires: nil,
			timeStamp: Date.now
		)
		message.body = .init(content: .text("Hey there, what's for dinner? Are we still going for Italian?"), caption: nil)
		return message
	}()
	
	static let noopDecryptedTextWithImageContextChat: Message = {
		var message = Message(
			id: "F",
			context: "A",
			decryptionKeys: [],
			encryptedBody: Body(content: .text("ENCRYPTED TEXT"), caption: nil),
			senderId: UUID().uuidString,
			reactions: [],
			tag: .chat,
			expires: nil,
			timeStamp: Date.now
		)
		message.body = .init(content: .text("Hey there, what's for dinner? Are we still going for Italian?"), caption: nil)
		return message
	}()
}

struct TribeMessage: Codable, Identifiable {
	let tribeId: Tribe.ID
	var messages: IdentifiedArrayOf<Message>
	var drafts: IdentifiedArrayOf<MessageDraft>
	
	var id: Tribe.ID { tribeId }
	
	var chat: IdentifiedArrayOf<Message> {
		IdentifiedArray(uniqueElements: messages.filter { $0.tag == .chat }.sorted(by: { $0.timeStamp < $1.timeStamp }))
	}
	
	var tea: IdentifiedArrayOf<Message> {
		IdentifiedArray(uniqueElements: messages.filter { $0.tag == .tea }.sorted(by: { $0.timeStamp < $1.timeStamp }))
	}
	
	var chatDrafts: IdentifiedArrayOf<MessageDraft> {
		IdentifiedArray(uniqueElements: drafts.filter { $0.tag == .chat }.sorted(by: { $0.timeStamp < $1.timeStamp }))
	}
	
	var teaDrafts: IdentifiedArrayOf<MessageDraft> {
		IdentifiedArray(uniqueElements: drafts.filter { $0.tag == .tea }.sorted(by: { $0.timeStamp < $1.timeStamp }))
	}
}

struct MessageDraft: Codable, Identifiable {
	enum Status: Codable {
		case uploading
		case failedToUpload
	}
	
	let id: UUID
	let content: Message.Body.Content
	let contextId: Message.ID?
	let caption: String?
	let tag: Message.Tag
	let tribeId: Tribe.ID
	var timeStamp: Date
	var status: Status = .uploading
	var pendingContent: PendingContent
	
	var isStuckUploading: Bool {
		Date.now.timeIntervalSince(timeStamp) > SizeConstants.draftRetryDelay
	}
}

extension MessageDraft {
	static let noop1: MessageDraft = MessageDraft(
		id: UUID(),
		content: .image("".unwrappedContentUrl),
		contextId: nil,
		caption: "This is our happy place. Please don't ruin it",
		tag: .tea,
		tribeId: Tribe.noop1.id,
		timeStamp: Date.now,
		status: .failedToUpload,
		pendingContent: PendingContent(
			id: UUID(),
			content: .image("".unwrappedContentUrl),
			encryptedData: nil
		)
	)
	
	static let noop2: MessageDraft = MessageDraft(
		id: UUID(),
		content: .text("Hey there, what is going on? This is our happy place."),
		contextId: nil,
		caption: nil,
		tag: .chat,
		tribeId: Tribe.noop1.id,
		timeStamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
		status: .uploading,
		pendingContent: PendingContent(
			id: UUID(),
			content: .image("".unwrappedContentUrl),
			encryptedData: nil
		)
	)
}
