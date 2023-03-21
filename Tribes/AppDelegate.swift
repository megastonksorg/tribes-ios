//
//  AppDelegate.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-19.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	
	override init() {
		super.init()
		UNUserNotificationCenter.current().delegate = self
	}
	
	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		let token: String = deviceToken.hexString
		APIClient.shared.updateDeviceToken(token)
	}
	
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void
	) {
		DeepLinkClient.shared.processNotification(response.notification.request.content.userInfo)
		completionHandler()
	}
}
