//
//  NotificationService.swift
//  TribesNotificationServiceExtension
//
//  Created by Kingsley Okeke on 2023-03-26.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
	
	var contentHandler: ((UNNotificationContent) -> Void)?
	var bestAttemptContent: UNMutableNotificationContent?
	
	//Clients
	let userDefaults = UserDefaults(suiteName: "group.com.strikingfinancial.Tribes")!
	let countKey: String = "badgeCount"
	
	override func didReceive(
		_ request: UNNotificationRequest,
		withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
	) {
		self.contentHandler = contentHandler
		bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
		
		var count: Int = {
			if let countInDefaults = userDefaults.value(forKey: countKey) as? Int {
				return countInDefaults
			} else {
				return 0
			}
		}()
		
		if let bestAttemptContent = bestAttemptContent {
			bestAttemptContent.title = "\(bestAttemptContent.title)"
			bestAttemptContent.body = "\(bestAttemptContent.body)"
			bestAttemptContent.badge = count as NSNumber
			count = count + 1
			userDefaults.set(count, forKey: countKey)
			contentHandler(bestAttemptContent)
		}
	}
	
	override func serviceExtensionTimeWillExpire() {
		// Called just before the extension will be terminated by the system.
		// Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
		if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
			contentHandler(bestAttemptContent)
		}
	}
}
