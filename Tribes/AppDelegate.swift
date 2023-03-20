//
//  AppDelegate.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-19.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
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
		let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
		let token = tokenParts.joined()
		//Send API request here to register the device
	}
}
