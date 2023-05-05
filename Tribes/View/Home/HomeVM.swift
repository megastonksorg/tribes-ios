//
//  HomeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-06.
//

import Combine
import UIKit

extension HomeView {
	@MainActor class ViewModel: ObservableObject {
		
		enum Page: Int {
			case compose
			case tribes
		}
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var user: User
		@Published var composeVM: ComposeView.ViewModel = ComposeView.ViewModel()
		@Published var tribesVM: TribesView.ViewModel
		
		@Published var isShowingCompose: Bool = false
		
		//Clients
		let keychainClient: KeychainClient = KeychainClient.shared
		
		init(user: User) {
			self.user = user
			self.tribesVM = TribesView.ViewModel(user: user)
			
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(userUpdated),
					name: .userUpdated,
					object: nil
				)
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(toggleCompose),
					name: .toggleCompose,
					object: nil
				)
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(openCompose),
					name: .openCompose,
					object: nil
				)
			
			registerForPushNotifications()
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
		
		@objc func openCompose() {
			self.composeVM.setDraftRecipient(nil)
			self.isShowingCompose = true
		}
		
		@objc func toggleCompose(notification: NSNotification) {
			if let dict = notification.userInfo as? NSDictionary {
				if let recipient = dict[AppConstants.composeNotificationDictionaryKey] as? Tribe {
					self.composeVM.setDraftRecipient(recipient)
					self.isShowingCompose = true
				}
			} else {
				self.isShowingCompose = false
			}
		}
		
		@objc func userUpdated() {
			if let user = keychainClient.get(key: .user) {
				self.user = user
				self.tribesVM.user = user
			}
		}
	}
}
