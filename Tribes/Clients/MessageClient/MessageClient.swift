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
	@Published var tribesAndMessages: IdentifiedArrayOf<TribeAndMessages> = []
	
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
			case .uiImage(let uiImage):
				guard let imageData = uiImage.pngData() else { return nil }
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
		case .uiImage:
			postMessageCancellables[draft.id] = self.apiClient.uploadImage(imageData: encryptedContent.data)
				.flatMap { [weak self] url -> AnyPublisher<MessageResponse, APIClientError>  in
					guard let self = self else { return Fail(error: APIClientError.rawError("The MessageClient could not upload your image")).eraseToAnyPublisher() }
					postMessageModel.body = url.absoluteString
					return self.apiClient.postMessage(model: postMessageModel, tag: draft.tag)
				}
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] messageResponse in
					self?.messagePosted(draft: draft, message: messageResponse)
				})
		case .video:
			postMessageCancellables[draft.id] = self.apiClient.uploadVideo(videoData: encryptedContent.data)
				.flatMap { [weak self] url -> AnyPublisher<MessageResponse, APIClientError>  in
					guard let self = self else { return Fail(error: APIClientError.rawError("The MessageClient could not upload your video")).eraseToAnyPublisher() }
					postMessageModel.body = url.absoluteString
					return self.apiClient.postMessage(model: postMessageModel, tag: draft.tag)
				}
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] messageResponse in
					self?.messagePosted(draft: draft, message: messageResponse)
				})
		case .text:
			postMessageModel.body = String(decoding: encryptedContent.data, as: UTF8.self)
			postMessageCancellables[draft.id] = self.apiClient.postMessage(model: postMessageModel, tag: draft.tag)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] messageResponse in
					self?.messagePosted(draft: draft, message: messageResponse)
				})
		case .image, .systemEvent:
			self.tribesAndMessages[id: draft.tribeId]?.chatDrafts.remove(id: draft.id)
			self.tribesAndMessages[id: draft.tribeId]?.teaDrafts.remove(id: draft.id)
			return
		}
	}
	
	func messagePosted(draft: MessageDraft, message: MessageResponse) {
		self.tribesAndMessages[id: draft.tribeId]?.chatDrafts.remove(id: draft.id)
		self.tribesAndMessages[id: draft.tribeId]?.teaDrafts.remove(id: draft.id)
		//Still need to process the messageResponse here
	}
}
