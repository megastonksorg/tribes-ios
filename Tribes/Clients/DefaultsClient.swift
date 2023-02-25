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
	
	private let encoder: JSONEncoder = JSONEncoder()
	private let decoder: JSONDecoder = JSONDecoder()
	private let defaults: UserDefaults = UserDefaults.standard
	
	func get<Data>(key: DefaultKey<Data>) -> Data? where Data : Codable {
		guard let dataObject = defaults.object(forKey: key.name) as? Foundation.Data else { return nil }
		return try? self.decoder.decode(Data.self, from: dataObject)
	}
	
	func set<Data>(key: DefaultKey<Data>, value: Data) where Data : Codable {
		let encodedData = try? self.encoder.encode(value)
		defaults.set(encodedData, forKey: key.name)
	}
}
