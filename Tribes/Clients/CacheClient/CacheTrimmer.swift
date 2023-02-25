//
//  CacheTrimmer.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-25.
//

import Foundation
import IdentifiedCollections

class CacheTrimmer {
	struct CacheTracker: Codable, Identifiable {
		let key: String
		let lastAccessed: Date
		
		var id: String { key }
	}
	
	private let cacheExpiryIntervalInSeconds: Double = 864_000 //10days = 10d * 24h * 3600s
	
	//Clients
	private let defaultsClient: DefaultsClient = DefaultsClient.shared
	
	func resetTracker() {
		defaultsClient.set(key: .cacheTracker, value: [])
	}
	
	func fileAccessed(key: String) {
		guard var cacheTracker = DefaultsClient.shared.get(key: .cacheTracker) else {
			defaultsClient.set(key: .cacheTracker, value: IdentifiedArrayOf(uniqueElements: [CacheTracker(key: key, lastAccessed: Date.now)]))
			return
		}
		cacheTracker.updateOrAppend(CacheTracker(key: key, lastAccessed: Date.now))
		defaultsClient.set(key: .cacheTracker, value: cacheTracker)
	}
	
	func removeTracker(for key: String) {
		guard var cacheTracker = DefaultsClient.shared.get(key: .cacheTracker) else { return }
		cacheTracker.remove(id: key)
		defaultsClient.set(key: .cacheTracker, value: cacheTracker)
	}
	
	func trimStaleData() {
		guard let cacheTracker = DefaultsClient.shared.get(key: .cacheTracker) else { return }
		cacheTracker.forEach { tracker in
			if Date.now.timeIntervalSince(tracker.lastAccessed) > cacheExpiryIntervalInSeconds {
				Task {
					await CacheClient.shared.delete(key: tracker.key)
				}
			}
		}
	}
}
