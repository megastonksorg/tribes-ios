//
//  DeepLinkClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-20.
//

import Foundation

class DeepLinkClient: ObservableObject {
	static let shared: DeepLinkClient = DeepLinkClient()
	
	@Published var pendingDeepLink: DeepLink?
	
	func setDeepLink(_ deepLink: DeepLink?) {
		self.pendingDeepLink = deepLink
	}
}
