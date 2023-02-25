//
//  CacheTrimmer.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-25.
//

import Foundation

class CacheTrimmer {
	struct CacheTracker: Codable, Identifiable {
		let key: String
		let lastAccessed: Date
		
		var id: String { key }
	}
	
	static let shared: CacheTrimmer = CacheTrimmer()
	
	private let cacheExpiryIntervalInSeconds: Double = 864_000 //10days = 10d * 24h * 3600s
	
	//Clients
	private let cacheClient: CacheClient = CacheClient.shared
	private let defaultsClient: DefaultsClient = DefaultsClient.shared
	
	init () {
		trimStaleData()
	}
	
	func resetTracker() {
		defaultsClient.set(key: .cacheTracker, value: [])
	}
	
	func fileAccessed(key: String) {
		guard var cacheTracker = DefaultsClient.shared.get(key: .cacheTracker) else { return }
		cacheTracker.updateOrAppend(CacheTracker(key: key, lastAccessed: Date.now))
		defaultsClient.set(key: .cacheTracker, value: cacheTracker)
	}
	
	func removeTracker(for key: String) {
		guard var cacheTracker = DefaultsClient.shared.get(key: .cacheTracker) else { return }
		cacheTracker.remove(id: key)
		defaultsClient.set(key: .cacheTracker, value: cacheTracker)
	}
	
	private func trimStaleData() {
		guard let oldCacheTracker = DefaultsClient.shared.get(key: .cacheTracker) else { return }
		oldCacheTracker.forEach { tracker in
			if Date.now.timeIntervalSince(tracker.lastAccessed) > cacheExpiryIntervalInSeconds {
				Task {
					await cacheClient.delete(key: tracker.key)
				}
			}
		}
	}
}
