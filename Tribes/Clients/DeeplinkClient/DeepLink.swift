//
//  Deeplink.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-20.
//

import Foundation

struct DeepLink {
	let messageId: Message.ID
	let type: DeepLinkType
}

enum DeepLinkType {
	case tea(_ tribeId: Tribe.ID)
	case chat(_ tribeId: Tribe.ID)
}

extension DeepLink {
	init?(tribeId: String, messageTag: String, messageId: Message.ID) {
		guard let messageTag = Message.Tag(rawValue: messageTag) else { return nil }
		switch messageTag {
		case .chat:
			self = DeepLink(messageId: messageId, type: .chat(tribeId))
		case .tea:
			self = DeepLink(messageId: messageId, type: .tea(tribeId))
		}
	}
}
