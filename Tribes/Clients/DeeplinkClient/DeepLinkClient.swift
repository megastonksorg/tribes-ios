//
//  DeeplinkClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-20.
//

import Foundation

class DeepLinkClient: ObservableObject {
	static let shared: DeepLinkClient = DeepLinkClient()
	
	@Published var pendingDeepLink: DeepLink?
	
	func processNotification(_ userInfo: [AnyHashable : Any]) {
		if let tribeId = userInfo["tribeId"] as? String,
		   let messageTag = userInfo["messageTag"] as? String,
		   let messageId = userInfo["messageId"] as? String
		{
			setDeepLink(DeepLink(tribeId: tribeId, messageTag: messageTag, messageId: messageId))
		}
	}
	
	func setDeepLink(_ deepLink: DeepLink?) {
		NotificationCenter.default.post(Notification(name: .toggleCompose))
		self.pendingDeepLink = deepLink
	}
}
