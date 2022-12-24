//
//  AppState.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-08-05.
//

import Foundation
import Combine

fileprivate let appStateKeyNotification: String = "appState"

@MainActor class AppState: ObservableObject {
	
	enum AppMode {
		case welcome(WelcomePageView.ViewModel)
		case authentication(AuthenticateView.ViewModel)
		case loggedIn
	}
	
	enum AppAction {
		case changeAppMode(AppMode)
	}
	
	@Published var appMode: AppMode = .welcome(WelcomePageView.ViewModel())
	
	init() {
		NotificationCenter
			.default.addObserver(
				self,
				selector: #selector(handleAppAction),
				name: .updateAppState,
				object: nil
			)
	}
	
	private func executeAppAction(action: AppAction) {
		switch action {
			case .changeAppMode(let mode):
				switch mode {
					case .welcome(let welcomeViewModel):
						self.appMode = .welcome(welcomeViewModel)
					case .authentication(let authenticationViewModel):
						self.appMode = .authentication(authenticationViewModel)
					case .loggedIn:
						self.appMode = .loggedIn
				}
		}
	}
	
	@objc func handleAppAction(notification: NSNotification) {
		if let dict = notification.userInfo as? NSDictionary {
			if let appAction = dict[appStateKeyNotification] as? AppAction{
				executeAppAction(action: appAction)
			}
		}
	}
}

extension AppState {
	static func updateAppState(with action: AppAction) {
		let notification = Notification(name: .updateAppState, userInfo: [appStateKeyNotification: action])
		
		NotificationCenter.default.post(notification)
	}
}
