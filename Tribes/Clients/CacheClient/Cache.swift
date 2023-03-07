//
//  Cache.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-03.
//

import CryptoKit
import Foundation
import IdentifiedCollections

struct Cache: Identifiable {
	let key: String
	let object: Codable
	
	var id: String { key }
}

extension Cache {
	static func getCacheKey(encryptedContent: Message.Body.Content) -> String? {
		switch encryptedContent {
		case .image(let url):
			return SHA256.getHash(for: url)
		case .video(let url):
			return "\(SHA256.getHash(for: url)).mp4"
		case .text, .systemEvent, .imageData:
			return nil
		}
	}
}

struct CacheKey<Object: Codable> {
	let name: String
}

extension CacheKey {
	static var tribes: CacheKey<IdentifiedArrayOf<Tribe>> { .init(name: "tribes") }
	static var tribesMessages: CacheKey<IdentifiedArrayOf<TribeMessage>> { .init(name: "tribesMessages") }
}
