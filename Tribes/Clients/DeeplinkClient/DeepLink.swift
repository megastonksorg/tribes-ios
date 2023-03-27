//
//  Deeplink.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-20.
//

import Foundation
import UIKit

struct DeepLink {
	enum `Type` {
		case tea(_ tribeId: Tribe.ID)
		case chat(_ tribeId: Tribe.ID)
	}
	
	let messageId: Message.ID
	let type: `Type`
}

extension DeepLink {
	init?(userInfo: [AnyHashable : Any]) {
		if let tribeId = userInfo["tribeId"] as? String,
		   let messageTag = userInfo["messageTag"] as? String,
		   let messageId = userInfo["messageId"] as? String
		{
			self.init(tribeId: tribeId, messageTag: messageTag, messageId: messageId)
		}
		return nil
	}
	
	init?(_ notification: UNNotification) {
		self.init(userInfo:  notification.request.content.userInfo)
	}
	
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
