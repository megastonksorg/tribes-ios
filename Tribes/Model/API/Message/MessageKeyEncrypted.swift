//
//  MessageKey.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-28.
//

import Foundation

struct MessageKeyEncrypted: Codable {
	let publicKey, encryptionKey: String
}
