//
//  AppState.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-08-05.
//

import Combine
import Foundation

fileprivate let appStateKeyNotification: String = "appState"

@MainActor class AppState: ObservableObject {
	
	enum AppMode {
		case welcome(WelcomePageView.ViewModel)
		case authentication(AuthenticateView.ViewModel)
		case home(HomeView.ViewModel)
	}
	
	enum AppAction {
		case changeAppMode(AppMode)
		case logUserOut
		case userUpdated(User)
	}
	
	let keychainClient = KeychainClient.shared
	let tribesRepository = TribesRepository.shared
	
	@Published var appMode: AppMode = .welcome(WelcomePageView.ViewModel())
	@Published var user: User?
	
	@Published var banner: BannerData?
	
	init() {
		NotificationCenter
			.default.addObserver(
				self,
				selector: #selector(handleAppAction),
				name: .updateAppState,
				object: nil
			)
		if let user = keychainClient.get(key: .user) {
			self.user = user
			self.appMode = .home(HomeView.ViewModel(user: user))
		}
	}
	
	private func executeAppAction(action: AppAction) {
		switch action {
			case .changeAppMode(let mode):
				switch mode {
					case .welcome(let welcomeViewModel):
						self.appMode = .welcome(welcomeViewModel)
					case .authentication(let authenticationViewModel):
						self.appMode = .authentication(authenticationViewModel)
					case .home(let homeViewModel):
						self.appMode = .home(homeViewModel)
				}
		case .logUserOut:
			self.banner = BannerData(timeOut: 8.0, detail: "Authentication Failed. You will be logged out soon.", type: .error)
			Task {
				try await Task.sleep(for: .seconds(8.0))
				keychainClient.clearAllKeys()
				self.appMode = .welcome(WelcomePageView.ViewModel())
			}
		case .userUpdated(let user):
			self.user = user
			switch self.appMode {
			case .home:
				self.keychainClient.set(key: .user, value: user)
				self.appMode = .home(HomeView.ViewModel(user: user))
			default: return
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
