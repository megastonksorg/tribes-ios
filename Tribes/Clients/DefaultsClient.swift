//
//  DefaultsClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-25.
//

import Foundation
import IdentifiedCollections

fileprivate enum KeyDefinitions: String, CaseIterable {
	case cacheTracker
	case badgeCount
	case didAuthenticationFail
}

protocol DefaultsClientProtocol {
	func get<Data: Codable>(key: DefaultKey<Data>) -> Data?
	func set<Data: Codable>(key: DefaultKey<Data>, value: Data)
	func clear()
}

struct DefaultKey<T: Codable> {
	let name: String
}


extension DefaultKey {
	static var cacheTracker: DefaultKey<IdentifiedArrayOf<CacheTrimmer.CacheTracker>> { .init(name: KeyDefinitions.cacheTracker.rawValue) }
	static var badgeCount: DefaultKey<Int> { .init(name: KeyDefinitions.badgeCount.rawValue) }
	static var didAuthenticationFail: DefaultKey<Bool> { .init(name: KeyDefinitions.didAuthenticationFail.rawValue) }
}

class DefaultsClient: DefaultsClientProtocol {
	static let shared: DefaultsClient = DefaultsClient()
	
	private let encoder: JSONEncoder = JSONEncoder()
	private let decoder: JSONDecoder = JSONDecoder()
	private let defaults: UserDefaults = UserDefaults(suiteName: "group.com.strikingfinancial.Tribes")!
	
	func get<Data>(key: DefaultKey<Data>) -> Data? where Data : Codable {
		guard let dataObject = defaults.object(forKey: key.name) as? Foundation.Data else { return nil }
		return try? self.decoder.decode(Data.self, from: dataObject)
	}
	
	func set<Data>(key: DefaultKey<Data>, value: Data) where Data : Codable {
		let encodedData = try? self.encoder.encode(value)
		defaults.set(encodedData, forKey: key.name)
	}
	
	func clear() {
		KeyDefinitions.allCases.forEach { key in
			defaults.removeObject(forKey: key.rawValue)
		}
	}
}
