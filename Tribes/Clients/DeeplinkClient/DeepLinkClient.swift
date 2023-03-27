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
		if let deepLink = DeepLink(userInfo: userInfo) {
			self.setDeepLink(deepLink)
		}
	}
	
	func setDeepLink(_ deepLink: DeepLink?) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			NotificationCenter.default.post(Notification(name: .toggleCompose))
			self.pendingDeepLink = deepLink
		}
	}
}
