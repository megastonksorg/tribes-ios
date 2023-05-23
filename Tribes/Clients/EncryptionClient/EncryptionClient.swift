//
//  EncryptionClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-15.
//

import CryptoKit
import Foundation

protocol EncryptionClientProtocol {
	func encrypt(_ data: Data, symmetricKey: SymmetricKey) -> EncryptedData?
	func encryptKey(symmetricKey: SymmetricKey, for publicKeys: Set<String>) -> [MessageKeyEncrypted]
	func decrypt(_ data: Data, for publicKey: String, key: String) -> Data?
}

extension EncryptionClientProtocol {
	func decryptString(_ base64String: String, for publicKey: String, key: String) -> String? {
		guard
			let data = Data(base64Encoded: base64String),
			let decryptedData = decrypt(data, for: publicKey, key: key) else { return nil }
		return String(decoding: decryptedData, as: UTF8.self)
	}
}

class EncryptionClient: EncryptionClientProtocol {
	static private (set) var shared: EncryptionClient = EncryptionClient()
	
	let rsaKeys: RSAKeys?
	
	init() {
		//The key should have been set here so it should never be nil at this point. This guard avoids crashes in the preview
		self.rsaKeys = {
			guard let savedMessageKey = KeychainClient.shared.get(key: .messageKey) else { return nil }
			return RSAKeys(messageKey: savedMessageKey)
		}()
	}
	
	func initialize() {
		EncryptionClient.shared = EncryptionClient()
	}
	
	func encrypt(_ data: Data, symmetricKey: SymmetricKey) -> EncryptedData? {
		if let encryptedData = encryptAES(message: data, key: symmetricKey) {
			return EncryptedData(key: symmetricKey.toBase64EncodedString(), data: encryptedData)
		} else {
			return nil
		}
	}
	
	func encryptKey(symmetricKey: SymmetricKey, for publicKeys: Set<String>) -> [MessageKeyEncrypted] {
		var keys: [MessageKeyEncrypted] = []
		publicKeys.forEach { pubKey in
			if let pubKeyData = Data(base64Encoded: pubKey),
			   let publicKey = RSAKeys.PublicKey(data: pubKeyData),
			   let symmetricKeyData = Data(base64Encoded: symmetricKey.toBase64EncodedString()),
			   let encryptedKey = publicKey.encrypt(data: symmetricKeyData) {
				keys.append(MessageKeyEncrypted(publicKey: pubKey, encryptionKey: encryptedKey.base64EncodedString()))
			}
		}
		return keys
	}
	
	func decrypt(_ data: Data, for publicKey: String, key: String) -> Data? {
		guard
			let rsaKeys = self.rsaKeys,
			publicKey == rsaKeys.publicKey.key.exportToData()?.base64EncodedString()
		else { return nil }
		if let encryptedKeyInDataFormat = Data(base64Encoded: key),
		   let decryptedKeyInStringFormat = rsaKeys.privateKey.decrypt(data: encryptedKeyInDataFormat)?.base64EncodedString() {
			return decryptAES(sealedMessage: data, key: decryptedKeyInStringFormat)
		} else {
			return nil
		}
	}
	
	private func encryptAES(message: Data, key: SymmetricKey) -> Data? {
		let sealedMessage = try? AES.GCM.seal(message, using: key)
		return sealedMessage?.combined
	}
	
	private func decryptAES(sealedMessage: Data, key: String) -> Data? {
		let sealedBox = try? AES.GCM.SealedBox(combined: sealedMessage)
		guard
			let keyData = Data(base64Encoded: key),
			let sealedBox = sealedBox
		else { return nil }
		let openedMessage = try? AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))
		return openedMessage
	}
}

extension SymmetricKey {
	func toBase64EncodedString() -> String {
		return self.withUnsafeBytes { body in
			Data(body).base64EncodedString()
		}
	}
}
