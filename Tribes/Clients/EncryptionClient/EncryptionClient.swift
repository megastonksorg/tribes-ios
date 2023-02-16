//
//  EncryptionClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-15.
//

import Foundation

protocol EncryptionClientProtocol {
	
}

class EncryptionClient: EncryptionClientProtocol {
	static let shared: EncryptionClient = EncryptionClient()
}
