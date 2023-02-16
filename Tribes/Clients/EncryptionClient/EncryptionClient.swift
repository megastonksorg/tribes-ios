//
//  EncryptionClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-15.
//

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
}
