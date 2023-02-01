//
//  Tribe.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-12.
//

import Foundation

struct Tribe: Decodable, Identifiable {
	let id: String
	let name: String
	let members: [TribeMember]
}

extension Tribe {
	static let noop: Tribe = Tribe(
		id: "1",
		name: "It's The Boys",
		members: [TribeMember.noop]
	)
	static let noop2: Tribe = Tribe(
		id: "2",
		name: "Team Zero",
		members: [TribeMember.noop]
	)
	static let noop3: Tribe = Tribe(
		id: "3",
		name: "Dark Thirty",
		members: [TribeMember.noop]
	)
	static let noop4: Tribe = Tribe(
		id: "4",
		name: "Never Sorry",
		members: [TribeMember.noop]
	)
}
