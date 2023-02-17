//
//  Authenticate.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-30.
//

import Foundation

struct AuthenticateRequest: Encodable {
	let walletAddress: String
	let messagePublicKey: String
	let signature: String
}

struct AuthenticateResponse: Decodable {
	let walletAddress: String
	let fullName: String
	let profilePhoto: URL
	let currency: String
	let acceptTerms: Bool
	let isOnboarded: Bool
	let jwtToken: String
	let refreshToken: String
}
