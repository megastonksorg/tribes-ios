//
//  MessageClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

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
	
	init() {
		
	}
	
	func postMessage(draft: MessageDraft) {
		guard let memberKeys: [String] = TribesRepository.shared.getTribe(tribeId: draft.tribeId)?.members.map({ $0.publicKey }) else { return }
		let symmetricKey = SymmetricKey(size: .bits256)
		let encryptedContent: EncryptedData? = {
			switch draft.content {
			case .uiImage(let uiImage):
				guard let imageData = uiImage.pngData() else { return nil }
				return EncryptionClient.shared.encrypt(imageData, for: memberKeys, symmetricKey: symmetricKey)
			case .text(let text):
				return EncryptionClient.shared.encrypt(Data(text.utf8), for: memberKeys, symmetricKey: symmetricKey)
			case .video(let url):
				guard let videoData = try? Data(contentsOf: url) else { return nil }
				return EncryptionClient.shared.encrypt(videoData, for: memberKeys, symmetricKey: symmetricKey)
			default: return nil
			}
		}()
		
		let encryptedCaption: String? = {
			guard
				let caption = draft.caption,
				let encryptedData = EncryptionClient.shared.encrypt(Data(caption.utf8), for: memberKeys, symmetricKey: symmetricKey)?.data
			else { return nil }
			let encryptedString = String(decoding: encryptedData, as: UTF8.self)
			return encryptedString.isEmpty ? nil : encryptedString
		}()
		
		guard let encryptedContent = encryptedContent else { return }
	}
}
