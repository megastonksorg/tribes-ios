//
//  AppDelegate.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-19.
//

import Combine
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	
	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	
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
	
	func application(
		_ application: UIApplication,
		didReceiveRemoteNotification userInfo: [AnyHashable : Any],
		fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
	) {
		guard let deepLink = DeepLink(userInfo: userInfo) else {
			completionHandler(.failed)
			return
		}
		APIClient
			.shared
			.getMessage(messageId: deepLink.messageId)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .finished: return
				case .failure: return
					completionHandler(.failed)
				}
			}, receiveValue: { messageResponse in
				MessageClient.shared.processMessageResponse(tribeId: deepLink.tribeId, messageResponse: messageResponse, wasReceived: false)
				Task {
					try await Task.sleep(for: .seconds(4.0))
					completionHandler(.newData)
				}
			})
			.store(in: &self.cancellables)
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
