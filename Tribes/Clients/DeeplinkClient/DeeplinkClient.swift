//
//  DeeplinkClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-20.
//

import Foundation

class DeeplinkClient: ObservableObject {
	static let shared: DeeplinkClient = DeeplinkClient()
	
	@Published var pendingDeeplink: Deeplink?
	
	func processNotification(_ userInfo: [AnyHashable : Any]) {
		if let tribeId = userInfo["tribeId"] as? String,
		   let messageTag = userInfo["messageTag"] as? String
		{
			setDeepLink(Deeplink(tribeId: tribeId, messageTag: messageTag))
		}
	}
	
	func setDeepLink(_ deeplink: Deeplink?) {
		self.pendingDeeplink = deeplink
	}
}
