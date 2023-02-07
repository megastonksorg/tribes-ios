//
//  CacheClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-03.
//

import Combine
import CryptoKit
import Foundation
import IdentifiedCollections
import SwiftUI

protocol CacheClientProtocol {
	func get<Object: Codable>(key: String, type: Object.Type) async -> Object?
	func set(cache: Cache) async -> Void
}

extension CacheClientProtocol {
	func setImage(url: URL, image: UIImage) async -> Void {
		guard let pngData = image.pngData() else { return }
		await set(cache: Cache(key: SHA256.hash(data: Data(url.absoluteString.utf8)).description, object: pngData))
	}
	
	func getImage(url: URL) async -> UIImage? {
		guard let imageData = await get(key: SHA256.hash(data: Data(url.absoluteString.utf8)).description, type: Data.self) else {
			return nil
		}
		return UIImage(data: imageData)
	}
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
	
	init() {
		if !FileManager.default.fileExists(atPath: cacheDirectory.path(), isDirectory: nil) {
			try! FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
		}
		self.memorySubscription = NotificationCenter
			.default
			.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
			.sink(receiveValue: { [weak self] _ in self?.cache = [] })
		Task {
			let fileSizes = await getSizeOfCache()
			if fileSizes > 500_000_000 { // 500 MB
				await clear()
			}
		}
	}
	
	func get<Object: Codable>(key: String, type: Object.Type) async -> Object? {
		await withCheckedContinuation { continuation in
			queue.async { [weak self] in
				guard let self = self else {
					continuation.resume(returning: nil)
					return
				}
				
				if let cachedItem = self.cache[id: key] {
					continuation.resume(returning:  cachedItem.object as? Object)
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
		queue.sync { [weak self] in
			guard let self = self else { return }
			guard let data = try? self.encoder.encode(cache.object) else { return }
			try? data.write(to: fileName(for: cache.key), options: [.atomic, .completeFileProtection])
			self.cache[id: cache.key] = cache
		}
	}
	
	private func clear() async {
		queue.sync { [weak self] in
			guard let self = self else { return }
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
					} catch { }
				}
			}
			for file in files {
				try? FileManager.default.removeItem(at: file)
			}
			self.cache = []
		}
	}
	
	private func getSizeOfCache() async -> Int {
		await withCheckedContinuation { continuation in
			queue.async { [weak self] in
				guard let self = self else {
					continuation.resume(with: .success(0))
					return
				}
				guard let urls = FileManager.default.enumerator(at: self.cacheDirectory, includingPropertiesForKeys: nil)?.allObjects as? [URL] else {
					continuation.resume(with: .success(0))
					return
				}
				
				do {
					let allFileSizes: Int = try urls.lazy
						.reduce(0) {
							(try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
						}
					continuation.resume(with: .success(allFileSizes))
					return
				} catch {
					continuation.resume(with: .success(0))
					return
				}
			}
		}
	}
	
	private func delete(key: String) async {
		queue.sync { [weak self] in
			guard let self = self else { return }
			try? FileManager.default.removeItem(at: fileName(for: key))
			self.cache.remove(id: key)
		}
	}
	
	private func fileName(for key: String) -> URL {
		return cacheDirectory.appendingPathComponent("cache_\(key)", isDirectory: false)
	}
}
