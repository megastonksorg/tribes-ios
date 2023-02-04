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
	func get<Object: Codable>(key: String, type: Object.Type) async -> Codable?
	func set(cache: Cache) async -> Void
}

class CacheClient: CacheClientProtocol {
	static let cacheFolderName: String = "cache"
	static let shared: CacheClient = CacheClient()
	
	private let cacheDirectory: URL = try! FileManager.default
		.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		.appendingPathComponent(cacheFolderName)
	private let encoder: JSONEncoder = JSONEncoder()
	private let decoder: JSONDecoder = JSONDecoder()
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
	
	func get<Object: Codable>(key: String, type: Object.Type) async -> Codable? {
		await withCheckedContinuation { continuation in
			self.queue.async { [weak self] in
				guard let self = self else {
					continuation.resume(returning: nil)
					return
				}
				
				if let cachedItem = self.cache[id: key] {
					continuation.resume(returning: cachedItem.object)
					return
				}
				
				guard let data = try? Data(contentsOf: self.fileName(for: key)),
					  let cachedObject = try? self.decoder.decode(type, from: data)
				else {
					continuation.resume(returning: nil)
					return
				}
				self.cache[id: key] = Cache(key: key, object: cachedObject)
				continuation.resume(returning: cachedObject)
			}
		}
	}
	
	func set(cache: Cache) async {
		await withCheckedContinuation { continuation in
			self.queue.sync { [weak self] in
				guard let self = self else {
					continuation.resume()
					return
				}
				guard let data = try? self.encoder.encode(cache.object) else { return }
				try? data.write(to: fileName(for: cache.key), options: [.atomic, .completeFileProtection])
				continuation.resume()
			}
		}
	}
	
	private func clear() async {
		await withCheckedContinuation { continuation in
			queue.sync { [weak self] in
				guard let self = self else {
					continuation.resume()
					return
				}
				var files = [URL]()
				if let enumerator = FileManager
					.default
					.enumerator(
						at: self.cacheDirectory,
						includingPropertiesForKeys: [.isRegularFileKey],
						options: [.skipsHiddenFiles, .skipsPackageDescendants]
					) {
					for case let fileURL as URL in enumerator {
						do {
							let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
							if fileAttributes.isRegularFile! {
								files.append(fileURL)
							}
						} catch { continuation.resume() }
					}
				}
				for file in files {
					try? FileManager.default.removeItem(at: file)
				}
				self.cache = []
				continuation.resume()
			}
		}
	}
	
	private func delete(key: String) async {
		await withCheckedContinuation { continuation in
			queue.sync { [weak self] in
				guard let self = self else {
					continuation.resume()
					return
				}
				try? FileManager.default.removeItem(at: fileName(for: key))
				self.cache.remove(id: key)
				continuation.resume()
			}
		}
	}
	
	private func fileName(for key: String) -> URL {
		return cacheDirectory.appendingPathComponent("cache_\(key)", isDirectory: false)
	}
}
