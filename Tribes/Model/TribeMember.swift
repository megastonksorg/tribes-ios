//
//  TribeMember.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-09.
//

import Foundation

struct TribeMember: Encodable, Identifiable {
	let id: String
	let name: String
	let photoURL: URL
}

extension TribeMember {
	static let noop: TribeMember = TribeMember(
		id: UUID().uuidString,
		name: "Kingsley Okeke",
		photoURL: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!
	)
}
