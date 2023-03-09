//
//  PostMessage.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation

struct PostMessage: Codable {
	var body: String
	let caption: String?
	let type: String
	let contextId: String?
	let tag: String
	let tribeId: Tribe.ID
	let tribeTimestampId: String
	let keys: [MessageKeyEncrypted]
}
