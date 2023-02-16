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
	static let shared: EncryptionClient = EncryptionClient()
	
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
