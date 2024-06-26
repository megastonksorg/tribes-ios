//
//  TribesApp.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-24.
//

import SwiftUI

@main
struct TribesApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	@Environment(\.scenePhase) var scenePhase
	
	//Clients
	private var hubClient: HubClient = HubClient.shared
	private var messageClient: MessageClient = MessageClient.shared
	
	var body: some Scene {
		WindowGroup {
			AppView()
				.onAppear {
					if let keyWindow = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) {
						keyWindow.overrideUserInterfaceStyle = .dark
					}
				}
		}
		.onChange(of: scenePhase) { newPhase in
			switch newPhase {
			case .active:
				self.hubClient.initializeConnection()
				TribesRepository.shared.refreshTribes()
			case .inactive:
				NotificationCenter.default.post(Notification(name: .appInActive, userInfo: [:]))
			case .background:
				self.messageClient.setAppBadge()
			@unknown default:
				return
			}
		}
	}
}
