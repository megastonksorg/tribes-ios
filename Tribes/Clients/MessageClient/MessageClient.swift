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

/**
 Sending a Message
 (1): Generate Encrypted Data
 (2): Send encrypted data across the wire if it is an image or video
 (3): Use received URL to compose PostMessageRequest
 (4): Encrypt and append caption if the user adds one
 */

@MainActor class MessageClient: ObservableObject {
	static let shared: MessageClient = MessageClient()
	
	@Published var tribesMessages: IdentifiedArrayOf<TribeMessage> = []
	
	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	private var postMessageCancellables: [MessageDraft.ID : AnyCancellable] = [:]
	
	//Clients
	let apiClient: APIClient = APIClient.shared
	let cacheClient: CacheClient = CacheClient.shared
	let encryptionClient: EncryptionClient = EncryptionClient.shared
	
	init() {
		Task {
			if let cachedTribesMessages = await cacheClient.getData(key: .tribesMessages) {
				await MainActor.run {
					self.tribesMessages = cachedTribesMessages
				}
				refreshMessages()
			} else {
				refreshMessages()
			}
		}
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
							self.tribesMessages.remove(id: staleId)
						}
						
						Task {
							//Update cache with the current tribesMessages to remove stale data
							await self.cacheClient.setData(key: .tribesMessages, value: self.tribesMessages)
							
							//Load New Messages
							messagesResponse.forEach { messageResponse in
								self.setAndLoadMessages(tribeId: tribe.id, messageResponse: messageResponse)
							}
						}
					}
				)
				.store(in: &cancellables)
		}
	}
	
	func postMessage(draft: MessageDraft) {
		//Add to Draft
		var draft = draft
		draft.status = .uploading
		self.tribesMessages[id: draft.tribeId]?.drafts.updateOrAppend(draft)
		
		//Encrypt Data
		guard let tribe: Tribe = TribesRepository.shared.getTribe(tribeId: draft.tribeId) else { return }
		let memberKeys: Set<String> = Set(tribe.members.map({ $0.publicKey }))
		
		let symmetricKey = SymmetricKey(size: .bits256)
		let encryptedContent: EncryptedData? = {
			switch draft.content {
			case .imageData(let imageData):
				return self.encryptionClient.encrypt(imageData, for: memberKeys, symmetricKey: symmetricKey)
			case .text(let text):
				return self.encryptionClient.encrypt(Data(text.utf8), for: memberKeys, symmetricKey: symmetricKey)
			case .video(let url):
				guard let videoData = try? Data(contentsOf: url) else { return nil }
				return self.encryptionClient.encrypt(videoData, for: memberKeys, symmetricKey: symmetricKey)
			case .image, .systemEvent: return nil
			}
		}()
		
		let encryptedCaptionString: String? = {
			guard
				let caption = draft.caption,
				let encryptedData = self.encryptionClient.encrypt(Data(caption.utf8), for: memberKeys, symmetricKey: symmetricKey)?.data
			else { return nil }
			let encryptedString = encryptedData.base64EncodedString()
			return encryptedString.isEmpty ? nil : encryptedString
		}()
		
		guard
			let encryptedContent = encryptedContent,
			let outgoingContentType = draft.content.outgoingType?.rawValue
		else { return }
		
		var postMessageModel: PostMessage = PostMessage(
			body: "",
			caption: encryptedCaptionString,
			type: outgoingContentType,
			contextId: draft.contextId,
			tag: draft.tag.rawValue,
			tribeId: tribe.id,
			tribeTimestampId: tribe.timestampId,
			keys: encryptedContent.keys
		)
		
		//Post Message
		switch draft.content {
		case .imageData:
			self.apiClient.uploadImage(imageData: encryptedContent.data)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { [weak self] url in
						guard let self = self else { return }
						postMessageModel.body = url.absoluteString
						self.postMessageCancellables[draft.id] = self.postMessage(draft: draft, model: postMessageModel)
					}
				)
				.store(in: &cancellables)
		case .video:
			self.apiClient.uploadVideo(videoData: encryptedContent.data)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { [weak self] url in
						guard let self = self else { return }
						postMessageModel.body = url.absoluteString
						self.postMessageCancellables[draft.id] = self.postMessage(draft: draft, model: postMessageModel)
					}
				)
				.store(in: &cancellables)
		case .text:
			postMessageModel.body = encryptedContent.data.base64EncodedString()
			postMessageCancellables[draft.id] = self.postMessage(draft: draft, model: postMessageModel)
		case .image, .systemEvent:
			self.tribesMessages[id: draft.tribeId]?.drafts.remove(id: draft.id)
			return
		}
	}
	
	private func decryptMessage(message: Message) {
		Task {
			let decryptedMessage: Message = message
			//Check the keys first
			guard
				let rsaKeys = encryptionClient.rsaKeys,
				let currentPublicKey = rsaKeys.publicKey.key.exportToData()?.base64EncodedString(),
				let messageKey = message.decryptionKeys.filter( { $0.publicKey == currentPublicKey } ).first,
				message.isEncrypted
			else { return }
			
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
				if let decryptedText = encryptionClient.decryptString(encryptedText, for: currentPublicKey, key: decryptionKey) {
					decryptedMessage.body = Message.Body(content: .text(decryptedText), caption: decryptedCaption)
					updateMessageAndCache(decryptedMessage)
				}
			case .image(let urlForData):
				guard
					let encryptedImageData = await self.apiClient.getMediaData(url: urlForData),
					let decryptedImageData = self.encryptionClient.decrypt(encryptedImageData, for: currentPublicKey, key: decryptionKey),
					let cacheKey = cacheKey
				else { return }
				
				let cachedImageUrl = await self.cacheClient.set(cache: Cache(key: cacheKey, object: decryptedImageData))
				decryptedMessage.body = Message.Body(content: .image(cachedImageUrl), caption: decryptedCaption)
				updateMessageAndCache(decryptedMessage)
			case .video(let urlForData):
				guard
					let encryptedVideoData = await self.apiClient.getMediaData(url: urlForData),
					let decryptedVideoData = self.encryptionClient.decrypt(encryptedVideoData, for: currentPublicKey, key: decryptionKey),
					let cacheKey = cacheKey
				else { return }
				
				let cachedVideoUrl = await self.cacheClient.set(cache: Cache(key: cacheKey, object: decryptedVideoData))
				decryptedMessage.body = Message.Body(content: .video(cachedVideoUrl), caption: decryptedCaption)
				updateMessageAndCache(decryptedMessage)
			case .systemEvent(let eventText):
				decryptedMessage.body = Message.Body(content: .systemEvent(eventText), caption: decryptedCaption)
				updateMessageAndCache(decryptedMessage)
			case .imageData:
				return
			}
		}
	}
	
	private func loadMessage(_ message: Message) {
		//Check if we need to decrypt the message.
		//If the message and it's content exists in the cache, don't decrypt. Just update the reaction because that is the only thing that could have been updated
		Task {
			if let tribeMessage = getTribeMessage(with: message.id) {
				if let existingTribesMessagesInCache = await self.cacheClient.getData(key: .tribesMessages) {
					if isMessageContentCached(message: message) && message.body != nil {
						if let messageToUpdate = existingTribesMessagesInCache[id: tribeMessage.id]?.messages.first(where: { $0.id == message.id }) {
							messageToUpdate.reactions = message.reactions
							updateMessageAndCache(messageToUpdate)
						}
					} else {
						decryptMessage(message: message)
					}
				}
			} else {
				decryptMessage(message: message)
			}
		}
	}
	
	private func updateMessageAndCache(_ message: Message) {
		if let tribeMessage = getTribeMessage(with: message.id) {
			DispatchQueue.main.async {
				self.tribesMessages[id: tribeMessage.id]?.messages[id: message.id] = message
			}
			Task {
				if var existingTribesMessagesInCache = await self.cacheClient.getData(key: .tribesMessages) {
					existingTribesMessagesInCache[id: tribeMessage.id]?.messages.updateOrAppend(message)
					await self.cacheClient.setData(key: .tribesMessages, value: existingTribesMessagesInCache)
				}
			}
		}
	}
	
	private func postMessage(draft: MessageDraft, model: PostMessage) -> AnyCancellable {
		return self.apiClient.postMessage(model: model)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { completion in
					switch completion {
					case .finished: return
					case .failure(let error):
						let expectedDataError: Data = Data("Invalid Tribe TimestampId".utf8)
						if error == .httpError(statusCode: 400, data: expectedDataError) {
							TribesRepository.shared
								.refreshTribes()
								.sink(
									receiveCompletion: { _ in },
									receiveValue: { _ in
										self.postMessage(draft: draft)
									}
								)
								.store(in: &self.cancellables)
						} else {
							var failedDraft = draft
							failedDraft.status = .failedToUpload
							self.tribesMessages[id: draft.tribeId]?.drafts.updateOrAppend(failedDraft)
						}
					}
				},
				receiveValue: { [weak self] messageResponse in
					self?.messagePosted(draft: draft, messageResponse: messageResponse)
				}
			)
	}
	
	private func messagePosted(draft: MessageDraft, messageResponse: MessageResponse) {
		self.tribesMessages[id: draft.tribeId]?.drafts.remove(id: draft.id)
		setAndLoadMessages(tribeId: draft.tribeId, messageResponse: messageResponse)
	}
	
	private func mapMessageResponseToMessage(_ messageResponse: MessageResponse) -> Message {
		return Message(
			id: messageResponse.id,
			context: messageResponse.context == nil ? nil : mapMessageResponseToMessage(messageResponse),
			decryptionKeys: messageResponse.keys,
			encryptedBody: Message.Body(
				content: getContentFromMessageResponse(messageResponse),
				caption: messageResponse.caption
			),
			senderId: messageResponse.senderWalletAddress,
			reactions: messageResponse.reactions.map {
				Message.Reaction(memberId: $0.senderWalletAddress, content: $0.content)
			},
			tag: messageResponse.tag,
			expires: messageResponse.expires?.utcToCurrent().date,
			timeStamp: messageResponse.timeStamp.utcToCurrent().date ?? Date.now
		)
	}
	
	private func setAndLoadMessages(tribeId: Tribe.ID, messageResponse: MessageResponse) {
		let messageToAppend: Message = mapMessageResponseToMessage(messageResponse)
		self.tribesMessages[id: tribeId]?.messages.updateOrAppend(messageToAppend)
		//Decrypt and Load Message Content
		loadMessage(messageToAppend)
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
		return CacheTrimmer().isFileTracked(key: cacheKey)
	}
	
	private func getTribeMessage(with id: Message.ID) -> TribeMessage? {
		return self.tribesMessages.first(where: { $0.messages.first(where: { $0.id == id }) != nil })
	}
}
