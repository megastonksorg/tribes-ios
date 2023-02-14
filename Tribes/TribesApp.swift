//
//  TribesApp.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-24.
//

import SwiftUI

@main
struct TribesApp: App {
	@Environment(\.scenePhase) var scenePhase
	
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
			if newPhase != .active {
				NotificationCenter.default.post(Notification(name: .appInActive, userInfo: [:]))
			}
		}
	}
}
