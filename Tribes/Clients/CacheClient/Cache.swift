//
//  Cache.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-03.
//

import Foundation
import IdentifiedCollections

struct Cache: Identifiable {
	let key: String
	let object: Codable
	
	var id: String { key }
}

struct CacheKey<Object: Codable> {
	let name: String
}

extension CacheKey {
	static var tribes: CacheKey<IdentifiedArrayOf<Tribe>> { .init(name: "tribes") }
	static var tribesMessages: CacheKey<IdentifiedArrayOf<TribeMessage>> { .init(name: "tribesMessages") }
}
