//
//  DefaultsClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-25.
//

import Foundation
import IdentifiedCollections

protocol DefaultsClientProtocol {
	func get<Data: Codable>(key: DefaultKey<Data>) -> Data?
	func set<Data: Codable>(key: DefaultKey<Data>, value: Data)
}

struct DefaultKey<T: Codable> {
	let name: String
}

extension DefaultKey {
	static var cacheTracker: DefaultKey<IdentifiedArrayOf<CacheTrimmer.CacheTracker>> { .init(name: "cacheTracker") }
}

class DefaultsClient: DefaultsClientProtocol {
	static let shared: DefaultsClient = DefaultsClient()
	
	private let defaults: UserDefaults = UserDefaults.standard
	
	func get<Data>(key: DefaultKey<Data>) -> Data? where Data : Codable {
		return defaults.object(forKey: key.name) as? Data
	}
	
	func set<Data>(key: DefaultKey<Data>, value: Data) where Data : Codable {
		defaults.set(value, forKey: key.name)
	}
}
