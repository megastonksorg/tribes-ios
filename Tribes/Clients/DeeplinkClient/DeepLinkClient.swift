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
		   let messageTag = userInfo["messageTag"] as? String
		{
			setDeepLink(DeepLink(tribeId: tribeId, messageTag: messageTag))
		}
	}
	
	func setDeepLink(_ deepLink: DeepLink?) {
		self.pendingDeepLink = deepLink
	}
}
