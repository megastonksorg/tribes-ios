//
//  User.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-30.
//

import Foundation

struct User: Encodable {
	let walletAddress: String
	let fullName: String
	let profilePhoto: URL
	let currency: String
	let acceptTerms: Bool
	let isOnboarded: Bool
}

extension User {
	static let noop: User = User(
		walletAddress: "0x1D1479C185d32EB90533a08b36B3CFa5F84A0E6B",
		fullName: "Full Name",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		currency: "USD",
		acceptTerms: false,
		isOnboarded: false
	)
}
