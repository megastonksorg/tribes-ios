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
	static let noop: TribeMember = TribeMember(
		fullName: "Kingsley Okeke",
		profilePhoto: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!,
		walletAddress: UUID().uuidString
	)
}
