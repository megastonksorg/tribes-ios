//
//  MessageKey.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-16.
//

import Foundation

struct MessageKey: Codable {
	let privateKey: String //Base64 Encoded RSA Private Key
	let publicKey: String //Base64 Encoded RSA Public Key
}
