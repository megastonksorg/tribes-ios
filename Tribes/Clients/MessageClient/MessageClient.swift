//
//  MessageClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Combine
import CryptoKit
import Foundation
import IdentifiedCollections
import UIKit

/**
 Sending a Message
 (1): Generate Encrypted Data
 (2): Send encrypted data across the wire if it is an image or video
 (3): Use received URL to compose PostMessageRequest
 (4): Encrypt and append caption if the user adds one
 */

@MainActor class MessageClient: ObservableObject {
	typealias ReadMessage = Set<Message.ID>
	
	enum MessageUpdateNotification {
		case updated(_ tribeId: Tribe.ID, _ message: Message)
		case deleted(_ tribeId: Tribe.ID, _ messageId: Message.ID)
		case draftsUpdated(_ tribeId: Tribe.ID, _ drafts: IdentifiedArrayOf<MessageDraft>)
	}
	
	static private (set) var shared: MessageClient = MessageClient()
	
	private let user: User?
	@Published var tribesMessages: IdentifiedArrayOf<TribeMessage> = []
	@Published var readMessage: ReadMessage = []
	
	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	private var postMessageCancellables: [MessageDraft.ID : AnyCancellable] = [:]
	
	//Clients
	private let apiClient: APIClient = APIClient.shared
	private let cacheClient: CacheClient = CacheClient.shared
	private let defaultsClient: DefaultsClient = DefaultsClient.shared
	private let encryptionClient: EncryptionClient = EncryptionClient.shared
	private let soundClient: SoundClient = SoundClient.shared
	private let keychainClient: KeychainClient = KeychainClient.shared
	
	init() {
		if let user = keychainClient.get(key: .user) {
			self.user = user
		} else {
			self.user = nil
		}
		Task {
			//Set tribesMessages
			if let cachedTribesMessages = await cacheClient.getData(key: .tribesMessages) {
				await MainActor.run {
					self.tribesMessages = cachedTribesMessages
				}
				refreshMessages()
			} else {
				refreshMessages()
			}
			//Set readMessage
			if let cachedReadMessage = await cacheClient.getData(key: .readMessage) {
				await MainActor.run {
					self.readMessage = cachedReadMessage
				}
			}
		}
	}
	
	func initialize() {
		MessageClient.shared = MessageClient()
	}
	
	func refreshMessages() {
		let tribes = TribesRepository.shared.getTribes()
		tribes.forEach { tribe in
			//If the tribe message does not exist, create a new one
			if self.tribesMessages[id: tribe.id] == nil {
				self.tribesMessages.updateOrAppend(
					TribeMessage(
						tribeId: tribe.id,
						messages: [],
						drafts: []
					)
				)
			}
			self.apiClient
				.getMessages(tribeId: tribe.id)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { [weak self] messagesResponse in
						guard let self = self else { return }
						//Remove Stale messages in tribesMessages
						let staleMessageIds: Set<String> = Set(self.tribesMessages[id: tribe.id]?.messages.ids.elements ?? []).subtracting(Set(messagesResponse.map { $0.id }))
						staleMessageIds.forEach { staleId in
							self.tribesMessages[id: tribe.id]?.messages.remove(id: staleId)
							self.readMessage.remove(staleId)
						}
						
						Task {
							//Update cache with the current tribesMessages to remove stale data
							await self.cacheClient.setData(key: .tribesMessages, value: self.tribesMessages)
							await self.cacheClient.setData(key: .readMessage, value: self.readMessage)
							//Load New Messages
							messagesResponse.forEach { messageResponse in
								self.processMessageResponse(tribeId: tribe.id, messageResponse: messageResponse, wasReceived: false)
							}
						}
					}
				)
				.store(in: &cancellables)
		}
	}
	
	func postDraft(_ draft: MessageDraft) {
		//Add to Draft
		var draft = draft
		draft.status = .uploading
		draft.timeStamp = Date.now
		self.tribesMessages[id: draft.tribeId]?.drafts.updateOrAppend(draft)
		
		//Send Message Update Notification
		let drafts = self.tribesMessages[id: draft.tribeId]?.drafts ?? []
		let notificationInfo: MessageUpdateNotification = .draftsUpdated(draft.tribeId, drafts)
		let messageUpdateNotification = Notification(name: .messageUpdated, userInfo: [AppConstants.messageNotificationDictionaryKey : notificationInfo])
		NotificationCenter.default.post(messageUpdateNotification)
		
		Task {
			await self.cacheClient.setData(key: .tribesMessages, value: self.tribesMessages)
		}
		
		//Retrieve Tribe
		guard let tribe: Tribe = TribesRepository.shared.getTribe(tribeId: draft.tribeId) else { return }
		
		//Retrieve Pending Content
		guard
			let pendingContent = PendingContentClient.shared.pendingContentSet[id: draft.pendingContent.id],
			let uploadedContent = pendingContent.uploadedContent
		else {
			// We are going to do nothing here because this means the pending content is still being uploaded
			return
		}
		
		//Retrieve Symmetric Key
		guard let symmetricKeyData = Data(base64Encoded: pendingContent.encryptedData.key) else { return }
		let symmetricKey = SymmetricKey(data: symmetricKeyData)
		
		//Encrypt Caption
		let encryptedCaptionString: String? = {
			guard
				let caption = draft.caption,
				let encryptedData = self.encryptionClient.encrypt(Data(caption.utf8), symmetricKey: symmetricKey)?.data
			else { return nil }
			let encryptedString = encryptedData.base64EncodedString()
			return encryptedString.isEmpty ? nil : encryptedString
		}()
		
		//Encrypt Keys for recipients
		let encryptedKeys: [MessageKeyEncrypted] = {
			let memberKeys = Set(tribe.members.map({ $0.publicKey }))
			return self.encryptionClient.encryptKey(symmetricKey: symmetricKey, for: memberKeys)
		}()
		
		guard
			let outgoingContentType = draft.content.outgoingType?.rawValue
		else {
			var failedDraft = draft
			failedDraft.status = .failedToUpload
			self.tribesMessages[id: draft.tribeId]?.drafts.updateOrAppend(failedDraft)
			
			//Send Message Update notification
			let drafts = self.tribesMessages[id: failedDraft.tribeId]?.drafts ?? []
			let notificationInfo: MessageUpdateNotification = .draftsUpdated(failedDraft.tribeId, drafts)
			let messageUpdateNotification = Notification(name: .messageUpdated, userInfo: [AppConstants.messageNotificationDictionaryKey : notificationInfo])
			NotificationCenter.default.post(messageUpdateNotification)
			
			return
		}
		
		var postMessageModel: PostMessage = PostMessage(
			body: "",
			caption: encryptedCaptionString,
			type: outgoingContentType,
			contextId: draft.contextId,
			tag: draft.tag.rawValue,
			tribeId: tribe.id,
			tribeTimestampId: tribe.timestampId,
			keys: encryptedKeys
		)
		
		//Post Message
		switch uploadedContent {
		case .image(let url), .video(let url):
			postMessageModel.body = url.absoluteString
			self.postMessageCancellables[draft.id] = self.postMessage(draft: draft, model: postMessageModel)
		case .text:
			postMessageModel.body = pendingContent.encryptedData.data.base64EncodedString()
			postMessageCancellables[draft.id] = self.postMessage(draft: draft, model: postMessageModel)
		case .imageData, .systemEvent:
			self.tribesMessages[id: draft.tribeId]?.drafts.remove(id: draft.id)
			
			//Send Message Update Notification
			let drafts = self.tribesMessages[id: draft.tribeId]?.drafts ?? []
			let notificationInfo: MessageUpdateNotification = .draftsUpdated(draft.tribeId, drafts)
			let messageUpdateNotification = Notification(name: .messageUpdated, userInfo: [AppConstants.messageNotificationDictionaryKey : notificationInfo])
			NotificationCenter.default.post(messageUpdateNotification)
			return
		}
	}
	
	func decryptMessage(message: Message, tribeId: Tribe.ID, wasReceived: Bool) {
		Task {
			var decryptedMessage: Message = message
			//Check the keys first
			guard
				let rsaKeys = encryptionClient.rsaKeys,
				let currentPublicKey = rsaKeys.publicKey.key.exportToData()?.base64EncodedString(),
				let messageKey = message.decryptionKeys.filter( { $0.publicKey == currentPublicKey } ).first,
				message.isEncrypted
			else {
				updateMessageAndCache(decryptedMessage, tribeId: tribeId, wasReceived: wasReceived)
				return
			}
			
			let decryptionKey: String = messageKey.encryptionKey
			
			//Decrypted Caption
			let decryptedCaption: String? = {
				guard
					let caption = message.encryptedBody.caption,
					let decryptedCaption = encryptionClient.decryptString(caption, for: currentPublicKey, key: decryptionKey)
				else { return nil }
				return decryptedCaption
			}()
			
			//CacheKey for Caching the message body content data
			let cacheKey = Cache.getContentCacheKey(encryptedContent: message.encryptedBody.content)
			
			//Decrypted Content
			switch message.encryptedBody.content {
			case .text(let encryptedText):
				guard
					let decryptedText = encryptionClient.decryptString(encryptedText, for: currentPublicKey, key: decryptionKey)
				else {
					updateMessageAndCache(decryptedMessage, tribeId: tribeId, wasReceived: wasReceived)
					return
				}
				
				decryptedMessage.body = Message.Body(content: .text(decryptedText), caption: decryptedCaption)
				updateMessageAndCache(decryptedMessage, tribeId: tribeId, wasReceived: wasReceived)
			case .image(let urlForData):
				guard
					let encryptedImageData = await self.apiClient.getMediaData(url: urlForData),
					let decryptedImageData = self.encryptionClient.decrypt(encryptedImageData, for: currentPublicKey, key: decryptionKey),
					let cacheKey = cacheKey
				else {
					updateMessageAndCache(decryptedMessage, tribeId: tribeId, wasReceived: wasReceived)
					return
				}
				
				let cachedImageUrl = await self.cacheClient.set(cache: Cache(key: cacheKey, object: decryptedImageData))
				decryptedMessage.body = Message.Body(content: .image(cachedImageUrl), caption: decryptedCaption)
				updateMessageAndCache(decryptedMessage, tribeId: tribeId, wasReceived: wasReceived)
			case .video(let urlForData):
				guard
					let encryptedVideoData = await self.apiClient.getMediaData(url: urlForData),
					let decryptedVideoData = self.encryptionClient.decrypt(encryptedVideoData, for: currentPublicKey, key: decryptionKey),
					let cacheKey = cacheKey
				else {
					updateMessageAndCache(decryptedMessage, tribeId: tribeId, wasReceived: wasReceived)
					return
				}
				
				let cachedVideoUrl = await self.cacheClient.set(cache: Cache(key: cacheKey, object: decryptedVideoData))
				decryptedMessage.body = Message.Body(content: .video(cachedVideoUrl), caption: decryptedCaption)
				updateMessageAndCache(decryptedMessage, tribeId: tribeId, wasReceived: wasReceived)
			case .systemEvent(let eventText):
				decryptedMessage.body = Message.Body(content: .systemEvent(eventText), caption: decryptedCaption)
				updateMessageAndCache(decryptedMessage, tribeId: tribeId, wasReceived: wasReceived)
			case .imageData:
				return
			}
		}
	}
	
	func deleteDraft(_ message: MessageDraft) {
		Task {
			if self.tribesMessages[id: message.tribeId]?.drafts[id: message.id] != nil {
				self.postMessageCancellables[message.id]?.cancel()
				self.tribesMessages[id: message.tribeId]?.drafts.remove(id: message.id)
				
				//Send Message Update Notification
				let drafts = self.tribesMessages[id: message.tribeId]?.drafts ?? []
				let notificationInfo: MessageUpdateNotification = .draftsUpdated(message.tribeId, drafts)
				let messageUpdateNotification = Notification(name: .messageUpdated, userInfo: [AppConstants.messageNotificationDictionaryKey : notificationInfo])
				NotificationCenter.default.post(messageUpdateNotification)
				await self.cacheClient.setData(key: .tribesMessages, value: self.tribesMessages)
			}
		}
	}
	
	func deleteMessage(_ message: Message, tribeId: Tribe.ID) {
		self.apiClient
			.deleteMessage(messageId: message.id)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { [weak self] response in
					if response.success {
						self?.messageDeleted(tribeId: tribeId, messageId: message.id)
					}
				}
			)
			.store(in: &self.cancellables)
	}
	
	func processMessageResponse(tribeId: Tribe.ID, messageResponse: MessageResponse, wasReceived: Bool) {
		let mappedMessage: Message = mapMessageResponseToMessage(messageResponse)
		if var messageToUpdate = self.tribesMessages[id: tribeId]?.messages[id: messageResponse.id],
		   isMessageContentCached(message: mappedMessage) {
			messageToUpdate.reactions = mappedMessage.reactions
			updateMessageAndCache(messageToUpdate, tribeId: tribeId, wasReceived: wasReceived)
		} else {
			//Decrypt and Load Message Content
			decryptMessage(message: mappedMessage, tribeId: tribeId, wasReceived: wasReceived)
		}
	}
	
	func messageDeleted(tribeId: Tribe.ID, messageId: Message.ID) {
		DispatchQueue.main.async {
			self.tribesMessages[id: tribeId]?.messages.remove(id: messageId)
		}
		
		//Send Message Update Notification
		let notificationInfo: MessageUpdateNotification = .deleted(tribeId, messageId)
		let messageUpdateNotification = Notification(name: .messageUpdated, userInfo: [AppConstants.messageNotificationDictionaryKey : notificationInfo])
		NotificationCenter.default.post(messageUpdateNotification)
		
		Task {
			await self.cacheClient.setData(key: .tribesMessages, value: self.tribesMessages)
		}
	}
	
	func markMessageAsRead(_ messageId: Message.ID) {
		DispatchQueue.main.async {
			self.readMessage.insert(messageId)
		}
		Task {
			await cacheClient.setData(key: .readMessage, value: self.readMessage)
		}
	}
	
	func setAppBadge() {
		Task {
			//Update Tribe Messages
			let tribeIds = Set(TribesRepository.shared.getTribes().map { $0.id })
			var tribeMessages = self.tribesMessages
			tribeMessages.removeAll(where: { !tribeIds.contains($0.tribeId) })
			
			DispatchQueue.main.async {
				self.tribesMessages = tribeMessages
			}
			await self.cacheClient.setData(key: .tribesMessages, value: self.tribesMessages)
			
			let unreadMessagesCount: Int = {
				var messageIds: Set<Message.ID> = []
				self.tribesMessages.elements.forEach { tribeMessage in
					let existingIds = messageIds
					messageIds = existingIds.union(Set( tribeMessage.messages.map { $0.id }))
				}
				return messageIds.subtracting(self.readMessage).count
			}()
			self.defaultsClient.set(key: .badgeCount, value: unreadMessagesCount)
			UIApplication.shared.applicationIconBadgeNumber = unreadMessagesCount
		}
	}
	
	private func updateMessageAndCache(_ message: Message, tribeId: Tribe.ID, wasReceived: Bool) {
		if self.tribesMessages[id: tribeId]?.messages[id: message.id] != message {
			DispatchQueue.main.async {
				self.tribesMessages[id: tribeId]?.messages[id: message.id] = message
			}
			if wasReceived {
				if message.senderId == self.user?.walletAddress {
					self.markMessageAsRead(message.id)
				} else {
					soundClient.playSound(.inAppNotification)
				}
			}
			//Send Message Update Notification
			let notificationInfo: MessageUpdateNotification = .updated(tribeId, message)
			let messageUpdateNotification = Notification(name: .messageUpdated, userInfo: [AppConstants.messageNotificationDictionaryKey : notificationInfo])
			NotificationCenter.default.post(messageUpdateNotification)
			
			Task {
				if var existingTribesMessagesInCache = await self.cacheClient.getData(key: .tribesMessages) {
					existingTribesMessagesInCache[id: tribeId]?.messages.updateOrAppend(message)
					await self.cacheClient.setData(key: .tribesMessages, value: existingTribesMessagesInCache)
				}
			}
		}
	}
	
	private func postMessage(draft: MessageDraft, model: PostMessage) -> AnyCancellable {
		return self.apiClient.postMessage(model: model)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] completion in
					guard let self = self else { return }
					switch completion {
					case .finished:
						self.deleteDraft(draft)
						self.soundClient.playSound(.messageSent)
						return
					case .failure(let error):
						let expectedDataError: Data = Data("Invalid Tribe TimestampId".utf8)
						if error == .httpError(statusCode: 400, data: expectedDataError) {
							TribesRepository.shared
								.refreshTribes()
								.sink(
									receiveCompletion: { _ in },
									receiveValue: { _ in
										self.postDraft(draft)
									}
								)
								.store(in: &self.cancellables)
						} else {
							var failedDraft = draft
							failedDraft.status = .failedToUpload
							self.tribesMessages[id: draft.tribeId]?.drafts.updateOrAppend(failedDraft)
							
							//Send Message Update notification
							let drafts = self.tribesMessages[id: failedDraft.tribeId]?.drafts ?? []
							let notificationInfo: MessageUpdateNotification = .draftsUpdated(failedDraft.tribeId, drafts)
							let messageUpdateNotification = Notification(name: .messageUpdated, userInfo: [AppConstants.messageNotificationDictionaryKey : notificationInfo])
							NotificationCenter.default.post(messageUpdateNotification)
						}
					}
				},
				receiveValue: { [weak self] messageResponse in
					self?.processMessageResponse(tribeId: model.tribeId, messageResponse: messageResponse, wasReceived: false)
				}
			)
	}
	
	private func mapMessageResponseToMessage(_ messageResponse: MessageResponse) -> Message {
		return Message(
			id: messageResponse.id,
			context: messageResponse.context,
			decryptionKeys: messageResponse.keys,
			encryptedBody: Message.Body(
				content: getContentFromMessageResponse(messageResponse),
				caption: messageResponse.caption
			),
			senderId: messageResponse.senderWalletAddress,
			reactions: messageResponse.reactions,
			tag: messageResponse.tag,
			expires: messageResponse.expires?.utcToCurrent().date,
			timeStamp: messageResponse.timeStamp.utcToCurrent().date ?? Date.now
		)
	}
	
	private func getContentFromMessageResponse(_ messageResponse: MessageResponse) -> Message.Body.Content {
		switch messageResponse.type {
		case .text:
			return .text(messageResponse.body)
		case .image:
			return .image(messageResponse.body.unwrappedContentUrl)
		case .video:
			return .video(messageResponse.body.unwrappedContentUrl)
		case .systemEvent:
			return .systemEvent(messageResponse.body)
		}
	}
	
	private func isMessageContentCached(message: Message) -> Bool {
		//Here, we assume the content is already cached if the cacheKey is nil
		//This is because the getCacheKey function only returns a key for image and video which are the only types that need to be fetched at this moment
		guard let cacheKey = Cache.getContentCacheKey(encryptedContent: message.encryptedBody.content) else { return true }
		return self.cacheClient.cacheTrimmer.isFileTracked(key: cacheKey)
	}
}
