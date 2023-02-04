//
//  CacheClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-03.
//

import Combine
import Foundation
import IdentifiedCollections
import SwiftUI

protocol CacheClientProtocol {
	func get(key: String) async -> Codable?
	func set(cache: Cache) async -> Void
}

class CacheClient: CacheClientProtocol {
	static let cacheFolderName: String = "cache"
	static let shared: CacheClient = CacheClient()
	
	private let cacheDirectory: URL = try! FileManager.default
		.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		.appendingPathComponent(cacheFolderName)
	private let queue = DispatchQueue(label: "com.strikingFinancial.tribes.cache.sessionQueue", target: .global())
	
	private var cache: IdentifiedArrayOf<Cache> = []
	private var memorySubscription: AnyCancellable!
	
	//Be sure to clear the stored cache in RAM as well
	init() {
		if !FileManager.default.fileExists(atPath: cacheDirectory.path(), isDirectory: nil) {
			try! FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
		}
		self.memorySubscription = NotificationCenter
			.default
			.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
			.sink(receiveValue: { [weak self] _ in self?.cache = [] })
	}
	
	func get(key: String) async -> Codable? {
		nil
	}
	
	func set(cache: Cache) async {
		()
	}
}
