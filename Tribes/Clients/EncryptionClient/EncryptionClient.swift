//
//  EncryptionClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-15.
//

import CryptoKit
import Foundation

protocol EncryptionClientProtocol {
	func encrypt(_ data: Data, for members: [TribeMember]) -> EncryptedData?
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
	
	func encrypt(_ data: Data, for members: [TribeMember]) -> EncryptedData? {
		let symmetricKey = SymmetricKey(size: .bits256)
		var keys: [TribeMember.ID : String] = [:]
		members.forEach { member in
			if let keyData = Data(base64Encoded: member.publicKey),
			   let publicKey = RSAKeys.PublicKey(data: keyData),
			   let encryptedKey = publicKey.encrypt(data: Data(symmetricKey.toBase64EncodedString().utf8)) {
				keys[member.id] = encryptedKey.base64EncodedString()
			}
		}
		if let encryptedData = encryptAES(message: data, key: symmetricKey) {
			return EncryptedData(keys: keys, data: encryptedData)
		} else {
			return nil
		}
	}
	
	func decrypt(_ data: Data, key: String) -> Data {
		return Data()
	}
	
	func encryptAES(message: Data, key: SymmetricKey) -> Data? {
		let sealedMessage = try? AES.GCM.seal(message, using: key)
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
