//
//  TribeMember.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-09.
//

import Foundation

struct TribeMember: Encodable {
	let name: String
	let photoURL: URL
}

extension TribeMember {
	static let noop: TribeMember = TribeMember(
		name: "Kingsley Okeke",
		photoURL: URL(string: "https://megastonksfilestoragedev.blob.core.windows.net/images/001d0c1e-a971-47cd-ad53-eb468e4d3d94.png")!
	)
}
