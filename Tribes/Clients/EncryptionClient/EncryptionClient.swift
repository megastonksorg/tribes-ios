//
//  EncryptionClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-15.
//

import CryptoKit
import Foundation

protocol EncryptionClientProtocol {
	func encrypt(_ data: Data, publicKey: String) -> Data
	func decrypt(_ data: Data, key: String) -> Data
}

class EncryptionClient: EncryptionClientProtocol {
	let rsaKeys: RSAKeys
	
	static let shared: EncryptionClient = EncryptionClient()
	
	init() {
		//The key should have been set here so it should never be nil at this point
		let savedMessageKey = KeychainClient.shared.get(key: .messageKey)!
		let privateKeyData = Data(base64Encoded: savedMessageKey.privateKey)!
		let publicKeyData = Data(base64Encoded: savedMessageKey.publicKey)!
		let privateKey = RSAKeys.PrivateKey(data: privateKeyData)!
		let publicKey = RSAKeys.PublicKey(data: publicKeyData)!
		self.rsaKeys = RSAKeys(privateKey: privateKey, publicKey: publicKey)
	}
	
	func encrypt(_ data: Data, publicKey: String) -> Data {
		return Data()
	}
	
	func decrypt(_ data: Data, key: String) -> Data {
		return Data()
	}
	
	func encryptAES(message: Data, key: String) -> Data? {
		guard let keyData = Data(base64Encoded: key) else { return nil }
		let sealedMessage = try? AES.GCM.seal(message, using: SymmetricKey(data: keyData))
		return sealedMessage?.combined
	}
	
	func decryptAES(sealedMessage: Data, key: String) -> Data? {
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
