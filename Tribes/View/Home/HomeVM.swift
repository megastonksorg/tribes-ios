//
//  HomeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-06.
//

import Foundation
import Combine

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
		
		@Published var currentPage: Page = .tribes
		
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
		}
		
		func setCurrentPage(page: Page) {
			self.currentPage = page
			switch page {
			case .compose: return
			case .tribes:
				self.composeVM.setDraftRecipient(nil)
				self.composeVM.cameraVM.didDisappear()
				self.composeVM.draftVM.didDisappear()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.composeVM.cameraVM.didDisappear()
				}
			}
		}
		
		func didNotCompletePageScroll() {
			switch currentPage {
			case .compose:
				DispatchQueue.main.async {
					self.setCurrentPage(page: .compose)
				}
				return
			case .tribes:
				self.composeVM.cameraVM.didDisappear()
			}
		}
		
		@objc func toggleCompose(notification: NSNotification) {
			if let dict = notification.userInfo as? NSDictionary {
				if let recipient = dict[AppConstants.composeNotificationDictionaryKey] as? Tribe {
					self.composeVM.setDraftRecipient(recipient)
					self.composeVM.cameraVM.didAppear()
					self.currentPage = .compose
				}
			} else {
				self.currentPage = .tribes
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
