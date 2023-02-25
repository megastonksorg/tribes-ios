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
	
	//Clients
	let cacheClient: CacheClient = CacheClient.shared
	let defaultsClient: DefaultsClient = DefaultsClient.shared
	
	func fileAccessed(key: String) {
		guard var cacheTracker = DefaultsClient.shared.get(key: .cacheTracker) else { return }
		cacheTracker.updateOrAppend(CacheTracker(key: key, lastAccessed: Date.now))
		defaultsClient.set(key: .cacheTracker, value: cacheTracker)
	}
	
	func trimStaleData() {
		
	}
}
