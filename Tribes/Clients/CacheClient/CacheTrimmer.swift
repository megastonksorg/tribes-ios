//
//  CacheTrimmer.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-25.
//

import Foundation
import IdentifiedCollections

struct CacheTrimmer {
	struct CacheTracker: Codable, Identifiable {
		let key: String
		let lastAccessed: Date
		
		var id: String { key }
	}
	
	private let cacheExpiryIntervalInSeconds: Double = 864_000 //10days = 10d * 24h * 3600s
	
	//Clients
	private let defaultsClient: DefaultsClient = DefaultsClient.shared
	
	func isFileTracked(key: String) -> Bool {
		guard let isTracked = defaultsClient.get(key: .cacheTracker)?.contains(where: { $0.key == key }) else { return false }
		return isTracked
	}
	
	func resetTracker() {
		defaultsClient.set(key: .cacheTracker, value: [])
	}
	
	func track(key: String) {
		guard var cacheTracker = DefaultsClient.shared.get(key: .cacheTracker) else {
			defaultsClient.set(key: .cacheTracker, value: IdentifiedArrayOf(uniqueElements: [CacheTracker(key: key, lastAccessed: Date.now)]))
			return
		}
		cacheTracker.updateOrAppend(CacheTracker(key: key, lastAccessed: Date.now))
		defaultsClient.set(key: .cacheTracker, value: cacheTracker)
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
