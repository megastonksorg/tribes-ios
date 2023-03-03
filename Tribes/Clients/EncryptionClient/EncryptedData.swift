//
//  EncryptedData.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-16.
//

import Foundation

struct EncryptedData {
	let keys: [MessageKeyEncrypted]
	let data: Data
}
