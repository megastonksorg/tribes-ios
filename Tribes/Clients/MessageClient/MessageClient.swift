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
	
	@Published var tribesAndMessages: IdentifiedArrayOf<TribeAndMessages> = []
	
	private var dataUploadCancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	private var postMessageCancellables: [MessageDraft.ID : AnyCancellable] = [:]
	
	//Clients
	let apiClient: APIClient = APIClient.shared
	let encryptionClient: EncryptionClient = EncryptionClient.shared
	
	init() {
		
	}
	
	func postMessage(draft: MessageDraft) {
		//Add to Draft
		switch draft.tag {
		case .chat:
			self.tribesAndMessages[id: draft.tribeId]?.chatDrafts.updateOrAppend(draft)
		case .tea:
			self.tribesAndMessages[id: draft.tribeId]?.teaDrafts.updateOrAppend(draft)
		}
		
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
		
		guard let encryptedContent = encryptedContent else { return }
		
		var postMessageModel: PostMessage = PostMessage(
			body: "",
			caption: encryptedCaptionString,
			type: draft.content.outgoingType,
			contextId: draft.contextId,
			tribeId: tribe.id,
			tribeTimeStampId: tribe.timestampId,
			keys: encryptedContent.keys
		)
		
		//Post Message
		switch draft.content {
		case .imageData:
			self.apiClient.uploadImage(imageData: encryptedContent.data)
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
			self.tribesAndMessages[id: draft.tribeId]?.chatDrafts.remove(id: draft.id)
			self.tribesAndMessages[id: draft.tribeId]?.teaDrafts.remove(id: draft.id)
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
					self?.messagePosted(draft: draft, message: messageResponse)
				}
			)
	}
	
	private func messagePosted(draft: MessageDraft, message: MessageResponse) {
		self.tribesAndMessages[id: draft.tribeId]?.chatDrafts.remove(id: draft.id)
		self.tribesAndMessages[id: draft.tribeId]?.teaDrafts.remove(id: draft.id)
		//Still need to process the messageResponse here
	}
}
