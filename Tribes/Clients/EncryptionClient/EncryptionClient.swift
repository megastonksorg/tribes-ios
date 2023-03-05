//
//  EncryptionClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-15.
//

import CryptoKit
import Foundation

protocol EncryptionClientProtocol {
	func encrypt(_ data: Data, for publicKeys: Set<String>, symmetricKey: SymmetricKey) -> EncryptedData?
	func decrypt(_ data: Data, for publicKey: String, key: String) -> Data?
}

extension EncryptionClientProtocol {
	func decryptString(_ string: String, for publicKey: String, key: String) -> String? {
		guard let decryptedData = decrypt(Data(string.utf8), for: publicKey, key: key) else { return nil }
		return String(decoding: decryptedData, as: UTF8.self)
	}
}

class EncryptionClient: EncryptionClientProtocol {
	static let shared: EncryptionClient = EncryptionClient()
	
	let rsaKeys: RSAKeys
	
	init() {
		//The key should have been set here so it should never be nil at this point
		let savedMessageKey = KeychainClient.shared.get(key: .messageKey)!
		let privateKeyData = Data(base64Encoded: savedMessageKey.privateKey)!
		let publicKeyData = Data(base64Encoded: savedMessageKey.publicKey)!
		let privateKey = RSAKeys.PrivateKey(data: privateKeyData)!
		let publicKey = RSAKeys.PublicKey(data: publicKeyData)!
		self.rsaKeys = RSAKeys(privateKey: privateKey, publicKey: publicKey)
	}
	
	func encrypt(_ data: Data, for publicKeys: Set<String>, symmetricKey: SymmetricKey) -> EncryptedData? {
		var keys: [MessageKeyEncrypted] = []
		publicKeys.forEach { pubKey in
			if let keyData = Data(base64Encoded: pubKey),
			   let publicKey = RSAKeys.PublicKey(data: keyData),
			   let encryptedKey = publicKey.encrypt(data: Data(symmetricKey.toBase64EncodedString().utf8)) {
				keys.append(MessageKeyEncrypted(publicKey: pubKey, encryptionKey: encryptedKey.base64EncodedString()))
			}
		}
		if let encryptedData = encryptAES(message: data, key: symmetricKey) {
			return EncryptedData(keys: keys, data: encryptedData)
		} else {
			return nil
		}
	}
	
	func decrypt(_ data: Data, for publicKey: String, key: String) -> Data? {
		guard publicKey == rsaKeys.publicKey.key.exportToData()?.base64EncodedString() else { return nil }
		if let encryptedKeyInDataFormat = Data(base64Encoded: key),
		   let decryptedKeyInStringFormat = self.rsaKeys.privateKey.decrypt(data: encryptedKeyInDataFormat)?.base64EncodedString() {
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

fileprivate extension SymmetricKey {
	func toBase64EncodedString() -> String {
		return self.withUnsafeBytes { body in
			Data(body).base64EncodedString()
		}
	}
}
