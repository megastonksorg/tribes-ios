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
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
	) -> Bool
	{
		if KeychainClient.shared.get(key: .user) != nil {
			registerForPushNotifications()
		}
		return true
	}
	
	func registerForPushNotifications() {
		UNUserNotificationCenter
			.current()
			.requestAuthorization(
				options: [.alert, .sound, .badge]
			) { granted, _ in
				guard granted else { return }
				UNUserNotificationCenter
					.current()
					.getNotificationSettings { settings in
						guard settings.authorizationStatus == .authorized else { return }
						DispatchQueue.main.async {
							UIApplication.shared.registerForRemoteNotifications()
						}
					}
			}
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
