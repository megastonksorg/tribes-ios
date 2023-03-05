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
	
	@Published var tribeMessages: IdentifiedArrayOf<TribeMessage> = []
	
	private var dataUploadCancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	private var postMessageCancellables: [MessageDraft.ID : AnyCancellable] = [:]
	
	//Clients
	let apiClient: APIClient = APIClient.shared
	let cacheClient: CacheClient = CacheClient.shared
	let encryptionClient: EncryptionClient = EncryptionClient.shared
	
	init() {
		
	}
	
	func decryptAndLoadMessageContent(_ message: Message) {
		let decryptedMessage: Message = message
		//Check the keys first
		guard
			let currentPublicKey = encryptionClient.rsaKeys.publicKey.key.exportToData()?.base64EncodedString(),
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
		
		//Decrypted Content
		switch message.encryptedBody.content {
		case .text(let encryptedText):
			if let decryptedText = encryptionClient.decryptString(encryptedText, for: currentPublicKey, key: decryptionKey) {
				decryptedMessage.body = Message.Body(content: .text(decryptedText), caption: decryptedCaption)
			}
		case .image(let urlForData):
			Task {
				guard
					let encryptedImageData = await self.apiClient.getMediaData(url: urlForData),
					let decryptedImageData = self.encryptionClient.decrypt(encryptedImageData, for: currentPublicKey, key: decryptionKey)
				else { return }
				
				let cachedImageUrl = await self.cacheClient.set(cache: Cache(key: SHA256.getHash(for: urlForData), object: decryptedImageData))
				decryptedMessage.body = Message.Body(content: .image(cachedImageUrl), caption: decryptedCaption)
			}
		case .video(let urlForData):
			Task {
				guard
					let encryptedVideoData = await self.apiClient.getMediaData(url: urlForData),
					let decryptedVideoData = self.encryptionClient.decrypt(encryptedVideoData, for: currentPublicKey, key: decryptionKey)
				else { return }
				
				let cachedVideoUrl = await self.cacheClient.set(cache: Cache(key: "\(SHA256.getHash(for: urlForData)).mp4", object: decryptedVideoData))
				decryptedMessage.body = Message.Body(content: .video(cachedVideoUrl), caption: decryptedCaption)
			}
		case .systemEvent(let eventText):
			decryptedMessage.body = Message.Body(content: .systemEvent(eventText), caption: decryptedCaption)
		case .imageData:
			return
		}
		
		//Update the Message in the tribesAndMessages then update it in the cache
		if let tribeMessage = self.tribeMessages.first(where: { $0.messages.first(where: { $0.id == message.id }) != nil }) {
			DispatchQueue.main.async {
				self.tribeMessages[id: tribeMessage.id]?.messages[id: message.id] = decryptedMessage
			}
		}
	}
	
	func postMessage(draft: MessageDraft) {
		//Add to Draft
		self.tribeMessages[id: draft.tribeId]?.drafts.updateOrAppend(draft)
		
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
			let encryptedString = String(decoding: encryptedData, as: UTF8.self)
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
			tribeId: tribe.id,
			tribeTimeStampId: tribe.timestampId,
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
						self.postMessageCancellables[draft.id] = self.postMessage(draft: draft, model: postMessageModel, tag: draft.tag)
					}
				)
				.store(in: &dataUploadCancellables)
		case .video:
			self.apiClient.uploadVideo(videoData: encryptedContent.data)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { [weak self] url in
						guard let self = self else { return }
						postMessageModel.body = url.absoluteString
						self.postMessageCancellables[draft.id] = self.postMessage(draft: draft, model: postMessageModel, tag: draft.tag)
					}
				)
				.store(in: &dataUploadCancellables)
		case .text:
			postMessageModel.body = String(decoding: encryptedContent.data, as: UTF8.self)
			postMessageCancellables[draft.id] = self.postMessage(draft: draft, model: postMessageModel, tag: draft.tag)
		case .image, .systemEvent:
			self.tribeMessages[id: draft.tribeId]?.drafts.remove(id: draft.id)
			return
		}
	}
	
	private func postMessage(draft: MessageDraft, model: PostMessage, tag: Message.Tag) -> AnyCancellable {
		return self.apiClient.postMessage(model: model, tag: tag)
			.catch { error -> AnyPublisher<MessageResponse, APIClientError> in
				let expectedDataError: Data = Data("Invalid Tribe TimestampId".utf8)
				let failureError: APIClientError = APIClientError.rawError("Something went wrong with the MessageClient")
				if error == .httpError(statusCode: 400, data: expectedDataError) {
					return TribesRepository.shared
						.refreshTribes()
						.flatMap { tribes -> AnyPublisher<MessageResponse, APIClientError> in
							if let newTribeTimestampId: String = tribes[id: model.tribeId]?.timestampId {
								let newPostMessageModel = PostMessage(
									body: model.body,
									caption: model.caption,
									type: model.type,
									contextId: model.contextId,
									tribeId: model.tribeId,
									tribeTimeStampId: newTribeTimestampId,
									keys: model.keys
								)
								return self.apiClient.postMessage(model: newPostMessageModel, tag: tag)
							} else {
								return Fail(error: failureError).eraseToAnyPublisher()
							}
						}
						.eraseToAnyPublisher()
				} else {
					return Fail(error: APIClientError.rawError("The MessageClient failed to send your message. Please try that again.")).eraseToAnyPublisher()
				}
			}
			.eraseToAnyPublisher()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { [weak self] messageResponse in
					self?.messagePosted(draft: draft, messageResponse: messageResponse)
				}
			)
	}
	
	private func messagePosted(draft: MessageDraft, messageResponse: MessageResponse) {
		self.tribeMessages[id: draft.tribeId]?.drafts.remove(id: draft.id)
		
		let messageToAppend: Message = mapMessageResponseToMessage(messageResponse)
		self.tribeMessages[id: draft.tribeId]?.messages.updateOrAppend(messageToAppend)
		//Still need to decrypt and process the messageResponse here
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
			expires: nil, //UPDATE
			timeStamp: Date.now //UPDATE
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
}

fileprivate extension String {
	var unwrappedContentUrl: URL { URL(string: self) ?? URL(string: "https://invalidContent.com")! }
}
