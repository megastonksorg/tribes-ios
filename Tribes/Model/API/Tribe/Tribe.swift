//
//  Tribe.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-12.
//

import Foundation
import IdentifiedCollections

struct Tribe: Codable, Identifiable {
	let id: String
	let name: String
	let timestampId: String
	let members: IdentifiedArrayOf<TribeMember>
}

extension IdentifiedArrayOf<TribeMember> {
	var others: IdentifiedArrayOf<TribeMember> {
		if let currentUser: User = KeychainClient.shared.get(key: .user) {
			return self.filter({ $0.walletAddress != currentUser.walletAddress })
		}
		return self
	}
}

extension Tribe {
	static let noop1: Tribe = Tribe(
		id: "1",
		name: "It's The Boys",
		timestampId: "stamp",
		members: []
	)
	static let noop2: Tribe = Tribe(
		id: "2",
		name: "Team Zero",
		timestampId: "stamp",
		members: [
			TribeMember.noop1,
			TribeMember.noop2,
			TribeMember.noop3,
			TribeMember.noop4,
			TribeMember.noop5,
			TribeMember.noop6,
			TribeMember.noop7,
			TribeMember.noop8,
			TribeMember.noop9,
		]
	)
	static let noop3: Tribe = Tribe(
		id: "3",
		name: "Men do not Lie. That is a fact 📠 ",
		timestampId: "stamp",
		members: [TribeMember.noop1]
	)
	static let noop4: Tribe = Tribe(
		id: "4",
		name: "Stop The Count",
		timestampId: "stamp",
		members: [TribeMember.noop1]
	)
	static let noop5: Tribe = Tribe(
		id: "5",
		name: "Are you coming or not?",
		timestampId: "stamp",
		members: [TribeMember.noop1]
	)
	static let noop6: Tribe = Tribe(
		id: "6",
		name: "Oh wow! It's the Boys!!",
		timestampId: "stamp",
		members: [TribeMember.noop1]
	)
	static let noop7: Tribe = Tribe(
		id: "7",
		name: "Dark 3030",
		timestampId: "stamp",
		members: [TribeMember.noop1]
	)
}
