//
//  CacheClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-03.
//

import Foundation
import IdentifiedCollections

protocol CacheClientProtocol {
	
}

class CacheClient: CacheClientProtocol {
	static let cacheFolderName: String = "cache"
	static let shared: CacheClient = CacheClient()
	
	let cacheDirectory: URL = try! FileManager.default
		.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		.appendingPathComponent(cacheFolderName)
	
	private var cache: IdentifiedArrayOf<Cache> = []
	
	//Be sure to clear the stored cache in RAM as well
	init() {
		if !FileManager.default.fileExists(atPath: cacheDirectory.path(), isDirectory: nil) {
			try! FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
		}
		
	}
}
