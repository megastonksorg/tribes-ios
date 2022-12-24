//
//  Authenticate.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-30.
//

import Foundation

struct AuthenticateRequest: Encodable {
	let walletAddress: String
	let signature: String
}

struct AuthenticateResponse: Decodable {
	let walletAddress: String
	let fullname: String
	let userName: String
	let profilePhoto: URL
	let currency: String
	let acceptTerms: Bool
	let isOnboarded: Bool
	let jwtToken: String
}
