//
//  KeychainClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-23.
//

import Foundation
import SwiftKeychainWrapper

fileprivate enum KeyDefinitions: String, CaseIterable {
	case mnemonic
	case messageKey
	case token
	case user
}

struct KeychainClientKey<T: Codable> {
	let name: String
}

extension KeychainClientKey {
	static var mnemonic: KeychainClientKey<String> { .init(name: KeyDefinitions.mnemonic.rawValue) }
	static var messageKey: KeychainClientKey<MessageKey> { .init(name: KeyDefinitions.messageKey.rawValue) }
	static var token: KeychainClientKey<Token> { .init(name: KeyDefinitions.token.rawValue) }
	static var user: KeychainClientKey<User> { .init(name: KeyDefinitions.user.rawValue) }
}

protocol KeychainClientProtocol {
	func get<Data: Codable>(key: KeychainClientKey<Data>) -> Data?
	func set<Data: Codable>(key: KeychainClientKey<Data>, value: Data, isLocked: Bool)
	func clearAllKeys()
}

class KeychainClient: KeychainClientProtocol {
	
	static let shared = KeychainClient()
	
	func get<Data>(key: KeychainClientKey<Data>) -> Data? where Data : Codable {
		if let data = KeychainWrapper.standard.data(forKey: KeychainWrapper.Key(rawValue: key.name)) {
			return try? JSONDecoder().decode(Data.self, from: data)
		}
		return nil
	}
	
	func set<Data>(key: KeychainClientKey<Data>, value: Data, isLocked: Bool = false) where Data : Codable {
		if let data = try? JSONEncoder().encode(value) {
			KeychainWrapper.standard.set(data, forKey: key.name, withAccessibility: isLocked ? .whenUnlocked : .alwaysThisDeviceOnly)
		}
	}
	
	func clearAllKeys() {
		KeyDefinitions.allCases.forEach { key in
			KeychainWrapper.standard.set("", forKey: key.rawValue, withAccessibility: .alwaysThisDeviceOnly)
		}
		KeychainWrapper.standard.removeAllKeys()
	}
}
