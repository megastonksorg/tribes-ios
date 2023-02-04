//
//  Cache.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-03.
//

import Foundation

struct Cache: Identifiable {
	let key: String
	let object: Codable
	
	var id: String { key }
}
