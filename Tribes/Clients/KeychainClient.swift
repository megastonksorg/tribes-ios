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
	case token
	case user
}

struct KeychainClientKey<T: Codable> {
	let name: String
}

extension KeychainClientKey {
	static var mnemonic: KeychainClientKey<String> { .init(name: KeyDefinitions.mnemonic.rawValue) }
	static var token: KeychainClientKey<Token> { .init(name: KeyDefinitions.token.rawValue) }
	static var user: KeychainClientKey<User> { .init(name: KeyDefinitions.user.rawValue) }
}

protocol KeychainClientProtocol {
	func get<Data: Codable>(key: KeychainClientKey<Data>) -> Data?
	func set<Data: Codable>(key: KeychainClientKey<Data>, value: Data)
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
	
	func set<Data>(key: KeychainClientKey<Data>, value: Data) where Data : Codable {
		if let data = try? JSONEncoder().encode(value) {
			KeychainWrapper.standard.set(data, forKey: key.name)
		}
	}
	
	func clearAllKeys() {
		KeyDefinitions.allCases.forEach { key in
			KeychainWrapper.standard.set("", forKey: key.rawValue)
		}
		KeychainWrapper.standard.removeAllKeys()
	}
}
