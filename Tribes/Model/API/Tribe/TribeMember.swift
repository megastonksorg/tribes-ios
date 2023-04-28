//
//  TribeMember.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-09.
//

import Foundation

struct TribeMember: Codable, Equatable, Identifiable, Hashable {
	let fullName: String
	let profilePhoto: URL
	let publicKey: String
	let walletAddress: String
	let joined: String
	var id: String { walletAddress }
}

extension TribeMember {
	static let dummyTribeMember: TribeMember = TribeMember(
		fullName: "User Left",
		profilePhoto: "".unwrappedContentUrl,
		publicKey: UUID().uuidString,
		walletAddress: "User Left",
		joined: ""
	)
	static let noop1: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
	static let noop2: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
	static let noop3: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
	static let noop4: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
	static let noop5: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
	static let noop6: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
	static let noop7: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
	static let noop8: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
	static let noop9: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		publicKey: UUID().uuidString,
		walletAddress: UUID().uuidString,
		joined: ""
	)
}
