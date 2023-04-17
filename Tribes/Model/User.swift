//
//  User.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-30.
//

import Foundation

struct User: Codable, Identifiable {
	let walletAddress: String
	var fullName: String
	var profilePhoto: URL
	let currency: String
	let acceptTerms: Bool
	let isOnboarded: Bool
	
	var id: String { walletAddress }
}

extension User {
	static let noop: User = User(
		walletAddress: "0x1D1479C185d32EB90533a08b36B3CFa5F84A0E6B",
		fullName: "Michael Richards",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		currency: "USD",
		acceptTerms: false,
		isOnboarded: false
	)
	static let noop2: User = User(
		walletAddress: "0x1D1479C185d32EB90533a08b36B3CFa5F84A0E6B",
		fullName: "Michael Richards",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpe")!,
		currency: "USD",
		acceptTerms: false,
		isOnboarded: false
	)
}
