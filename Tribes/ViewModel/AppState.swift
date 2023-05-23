//
//  AppState.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-08-05.
//

import Combine
import Foundation
import UIKit

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
		case userRequestedLogout
		case userUpdated(User)
		case userDeleted
	}
	
	@Published var appMode: AppMode = .welcome(WelcomePageView.ViewModel())
	@Published var user: User?
	
	@Published var banner: BannerData?
	
	//Clients
	let cacheClient = CacheClient.shared
	let defaultsClient = DefaultsClient.shared
	let hubClient = HubClient.shared
	let keyboardClient = KeyboardClient.shared
	let keychainClient = KeychainClient.shared
	let tribesRepository = TribesRepository.shared
	
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
			if let didAuthenticationFail = defaultsClient.get(key: .didAuthenticationFail),
				didAuthenticationFail {
				self.appMode = .authentication(AuthenticateView.ViewModel(context: .signIn, user: user))
			} else {
				self.appMode = .home(HomeView.ViewModel(user: user))
			}
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
				//Reinitialize clients
				EncryptionClient.shared.initialize()
				MessageClient.shared.initialize()
				
				self.appMode = .home(homeViewModel)
			}
		case .logUserOut:
			switch appMode {
			case .home:
				self.banner = BannerData(timeOut: 8.0, detail: "Authentication Failed. You will be logged out soon.", type: .error)
				logOut(isUserRequested: false)
			default:
				return
			}
		case .userRequestedLogout, .userDeleted :
			logOut(isUserRequested: true)
		case .userUpdated(let user):
			self.user = user
			switch self.appMode {
			case .home:
				self.keychainClient.set(key: .user, value: user)
				NotificationCenter.default.post(Notification(name: .userUpdated))
			default: return
			}
		}
	}
	
	private func logOut(isUserRequested: Bool) {
		//Resign Keyboard across app before logout
		keyboardClient.resignKeyboard()
		AppRouter.popToRoot(stack: .welcome())
		AppRouter.popToRoot(stack: .home())
		
		if isUserRequested {
			self.cacheClient.clear()
			self.defaultsClient.clear()
			self.keychainClient.clearAllKeys()
			self.hubClient.stopConnection()
			
			MessageClient.shared.initialize()
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
				self.appMode = .welcome(WelcomePageView.ViewModel())
			}
		} else {
			Task {
				if let user = user {
					try await Task.sleep(for: .seconds(8.0))
					self.defaultsClient.set(key: .didAuthenticationFail, value: true)
					self.hubClient.stopConnection()
					MessageClient.shared.initialize()
					
					await MainActor.run {
						self.appMode = .authentication(AuthenticateView.ViewModel(context: .signIn, user: user))
					}
				}
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
