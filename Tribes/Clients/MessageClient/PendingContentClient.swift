//
//  PendingContentClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-13.
//

import Combine
import CryptoKit
import Foundation
import IdentifiedCollections

struct PendingContent: Codable, Equatable, Identifiable {
	let id: UUID
	let content: Message.Body.Content
	let encryptedData: EncryptedData
	var uploadedContent: Message.Body.Content?
}

@MainActor class PendingContentClient: ObservableObject {
	static private (set) var shared: PendingContentClient = PendingContentClient()
	
	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	
	//Clients
	private let apiClient: APIClient = APIClient.shared
	private let encryptionClient: EncryptionClient = EncryptionClient.shared
	private let messageClient: MessageClient = MessageClient.shared
	
	@Published var pendingContentSet: IdentifiedArrayOf<PendingContent> = []
	
	init() {
		
	}
	
	func set(content: Message.Body.Content) -> PendingContent? {
		let symmetricKey: SymmetricKey = SymmetricKey(size: .bits256)
		
		let encryptedData: EncryptedData? = {
			switch content {
			case .imageData(let imageData):
				return self.encryptionClient.encrypt(imageData, symmetricKey: symmetricKey)
			case .text(let text):
				return self.encryptionClient.encrypt(Data(text.utf8), symmetricKey: symmetricKey)
			case .video(let url):
				guard let videoData = try? Data(contentsOf: url) else { return nil }
				return self.encryptionClient.encrypt(videoData, symmetricKey: symmetricKey)
			case .image, .systemEvent: return nil
			}
		}()
		
		guard let encryptedData = encryptedData else { return nil }
		
		/**
		 Because we do not have to upload anything for text, the uploaded content will be the same as the content.
		 This is because we use the uploaded content to determine when a content is ready to be uploaded.
		 Essentially, here we are saying that text is ready to be uploaded right away
		 This is because it does not have any media that needs to be preflighted if you will.
		 */
		let uploadedContent: Message.Body.Content? = {
			switch content {
			case .imageData, .video, .image, .systemEvent: return nil
			case .text: return content
			}
		}()
		
		let newPendingContent = PendingContent(
			id: UUID(),
			content: content,
			encryptedData: encryptedData,
			uploadedContent: uploadedContent
		)
		
		self.pendingContentSet.updateOrAppend(newPendingContent)
		
		uploadContent(newPendingContent)
		return newPendingContent
	}
	
	func uploadContent(_ pendingContent: PendingContent) {
		let data = pendingContent.encryptedData.data
		switch pendingContent.content {
		case .imageData:
			self.apiClient.uploadImage(imageData: data)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { [weak self] url in
						guard let self = self else { return }
						self.pendingContentSet[id: pendingContent.id]?.uploadedContent = .image(url)
						self.updateDraft(with: pendingContent)
					}
				)
				.store(in: &cancellables)
		case .video:
			self.apiClient.uploadVideo(videoData: data)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { [weak self] url in
						guard let self = self else { return }
						self.pendingContentSet[id: pendingContent.id]?.uploadedContent = .video(url)
						self.updateDraft(with: pendingContent)
					}
				)
				.store(in: &cancellables)
		case .text, .image, .systemEvent:
			return
		}
	}
	
	private func updateDraft(with pendingContent: PendingContent) {
		let tribes = TribesRepository.shared.getTribes()
		
		tribes.forEach { tribe in
			if var correspondingDraft = self.messageClient.tribesMessages[id: tribe.id]?.drafts.first(where: { $0.pendingContent.id == pendingContent.id }) {
				self.messageClient.tribesMessages[id: tribe.id]?.drafts[id: correspondingDraft.id]?.pendingContent = pendingContent
				
				//Post draft if needed
				
			}
		}
	}
}
