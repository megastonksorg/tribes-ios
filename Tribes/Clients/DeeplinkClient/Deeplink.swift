//
//  Deeplink.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-20.
//

import Foundation

enum Deeplink {
	case tea(_ tribeId: Tribe.ID)
	case chat(_ tribeId: Tribe.ID)
}

extension Deeplink {
	init(_ deepLinkResponse: DeeplinkResponse) {
		switch deepLinkResponse.messageTag {
		case .chat:
			self = Deeplink.chat(deepLinkResponse.tribeId)
		case .tea:
			self = Deeplink.tea(deepLinkResponse.tribeId)
		}
	}
}
