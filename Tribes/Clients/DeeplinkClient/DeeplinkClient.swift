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
	
	func setDeepLink(_ deeplink: Deeplink?) {
		self.pendingDeeplink = deeplink
	}
}
