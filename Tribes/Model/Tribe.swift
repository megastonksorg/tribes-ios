//
//  Tribe.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-12.
//

import Foundation

struct Tribe: Encodable, Identifiable {
	let id: String
	let name: String
	let members: [TribeMember]
}

extension Tribe {
	static let noop: Tribe = Tribe(
		id: "1234565",
		name: "It's The Boys",
		members: [TribeMember.noop]
	)
}
