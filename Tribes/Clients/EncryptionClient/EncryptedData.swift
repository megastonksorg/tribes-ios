//
//  EncryptedData.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-16.
//

import Foundation

struct EncryptedData: Codable, Equatable {
	let key: String
	let data: Data
}
