//
//  TribeMember.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-09.
//

import Foundation

struct TribeMember: Decodable, Identifiable {
	let fullName: String
	let profilePhoto: URL
	let walletAddress: String
	
	var id: String { walletAddress }
}

extension TribeMember {
	static let noop1: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		walletAddress: UUID().uuidString
	)
	static let noop2: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		walletAddress: UUID().uuidString
	)
	static let noop3: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		walletAddress: UUID().uuidString
	)
	static let noop4: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		walletAddress: UUID().uuidString
	)
	static let noop5: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		walletAddress: UUID().uuidString
	)
	static let noop6: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		walletAddress: UUID().uuidString
	)
}
