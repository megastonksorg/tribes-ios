//
//  Deeplink.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-20.
//

import Foundation

enum DeepLink {
	case tea(_ tribeId: Tribe.ID)
	case chat(_ tribeId: Tribe.ID)
}

extension DeepLink {
	init?(tribeId: String, messageTag: String) {
		guard let messageTag = Message.Tag(rawValue: messageTag) else { return nil }
		switch messageTag {
		case .chat:
			self = DeepLink.chat(tribeId)
		case .tea:
			self = DeepLink.tea(tribeId)
		}
	}
}
