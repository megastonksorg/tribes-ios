//
//  PostMessageRequest.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation

struct PostMessageRequest {
	let body: String
	let caption: String?
	let type: String
	let contextId: String?
	let tribeId: Tribe.ID
	let tribeTimeStampId: String
	let keys: [MessageKeyEncrypted]
}
