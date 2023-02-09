//
//  Tribe.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-12.
//

import Foundation

struct Tribe: Codable, Identifiable {
	let id: String
	let name: String
	let members: [TribeMember]
}

extension Tribe {
	static let noop1: Tribe = Tribe(
		id: "1",
		name: "It's The Boys",
		members: []
	)
	static let noop2: Tribe = Tribe(
		id: "2",
		name: "Team Zero",
		members: [
			TribeMember.noop1,
			TribeMember.noop2,
			TribeMember.noop3,
			TribeMember.noop4,
			TribeMember.noop5,
			TribeMember.noop6
		]
	)
	static let noop3: Tribe = Tribe(
		id: "3",
		name: "Men do not Lie. That is a fact 📠 ",
		members: [TribeMember.noop1]
	)
	static let noop4: Tribe = Tribe(
		id: "4",
		name: "Stop The Count",
		members: [TribeMember.noop1]
	)
	static let noop5: Tribe = Tribe(
		id: "5",
		name: "Are you coming or not?",
		members: [TribeMember.noop1]
	)
	static let noop6: Tribe = Tribe(
		id: "6",
		name: "Oh wow! It's the Boys!!",
		members: [TribeMember.noop1]
	)
	static let noop7: Tribe = Tribe(
		id: "7",
		name: "Dark 3030",
		members: [TribeMember.noop1]
	)
}
