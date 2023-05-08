//
//  TribesVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-15.
//

import Combine
import Foundation
import IdentifiedCollections
import SwiftUI

extension TribesView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: String, Hashable, Identifiable {
			case editTribeName
			
			var id: String { self.rawValue }
		}
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var banner: BannerData?
		@Published var accountVM: AccountView.ViewModel
		@Published var tribeInviteVM: TribeInviteView.ViewModel?
		@Published var tribes: IdentifiedArrayOf<Tribe>
		@Published var user: User
		@Published var currentTeaTribe: Tribe?
		
		@Published var isShowingAccountView: Bool = false
		@Published var isShowingTribeInvite: Bool = false
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		private let deepLinkClient: DeepLinkClient = DeepLinkClient.shared
		private let feedbackClient: FeedbackClient = FeedbackClient.shared
		private let tribesRepository: TribesRepository = TribesRepository.shared
		
		init(tribes: IdentifiedArrayOf<Tribe> = TribesRepository.shared.getTribes(), user: User) {
			self.accountVM = AccountView.ViewModel(user: user)
			self.tribes = tribes
			self.user = user
			
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(updateTribe),
					name: .tribesUpdated,
					object: nil
				)
			
			self.deepLinkClient
				.$pendingDeepLink
				.sink(receiveValue: { deepLink in
					guard let deepLink = deepLink else { return }
					switch deepLink.type {
					case .tea(let tribeId):
						if let tribe = self.tribes[id: tribeId] {
							self.setCurrentTeaTribe(tribe)
							self.deepLinkClient.setDeepLink(nil)
						}
						return
					case .chat(let tribeId):
						if let tribe = self.tribes[id: tribeId] {
							self.showTribeChat(tribe)
							self.deepLinkClient.setDeepLink(nil)
						}
						return
					}
				})
				.store(in: &cancellables)
		}
		
		func createTribe() {
			AppRouter.pushStack(stack: .home(.createTribe))
		}
		
		func showTribeInviteCopyBanner() {
			self.banner = BannerData(detail: "Pin Code copied to clipboard", type: .success)
		}
		
		func joinTribe() {
			AppRouter.pushStack(stack: .home(.joinTribe))
		}
		
		func loadTribes() {
			tribesRepository.refreshTribes()
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
						case .finished: return
						case .failure(let error):
							self?.banner = BannerData(error: error)
						}
					},
					receiveValue: { [weak self] tribes in
						self?.tribes = tribes
					}
				)
				.store(in: &cancellables)
		}
		
		func toggleAccountView() {
			if !self.isShowingAccountView {
				self.accountVM = AccountView.ViewModel(user: self.user)
			}
			self.isShowingAccountView.toggle()
		}
		
		func setCurrentTeaTribe(_ tribe: Tribe?) {
			withAnimation(.easeInOut) {
				self.currentTeaTribe = tribe
			}
		}
		
		func showTribeChat(_ tribe: Tribe) {
			AppRouter.pushStack(stack: .home(.chat(tribe: tribe)))
		}
		
		func openCompose(_ tribe: Tribe?) {
			guard let tribe = tribe else {
				NotificationCenter.default.post(Notification(name: .openCompose))
				self.feedbackClient.medium()
				return
			}
			if tribe.members.others.count > 0 {
				NotificationCenter.default.post(Notification(name: .toggleCompose, userInfo: [AppConstants.composeNotificationDictionaryKey: tribe]))
				self.feedbackClient.medium()
			}
		}
		
		func tribePrimaryActionTapped(_ tribe: Tribe) {
			if tribe.members.others.count == 0 {
				showTribeInviteCard(tribe: tribe)
			} else {
				setCurrentTeaTribe(tribe)
			}
		}
		
		func tribeSecondaryActionTapped(_ tribe: Tribe) {
			showTribeChat(tribe)
		}
		
		func tribeInviteActionTapped(_ tribe: Tribe) {
			self.showTribeInviteCard(tribe: tribe)
		}
		
		func showTribeInviteCard(tribe: Tribe) {
			withAnimation(Animation.cardViewAppear) {
				self.isShowingTribeInvite = true
				self.tribeInviteVM = TribeInviteView.ViewModel(tribe: tribe)
			}
		}
		
		func dismissTribeInviteCard() {
			withAnimation(Animation.cardViewDisappear) {
				self.isShowingTribeInvite = false
				self.tribeInviteVM = nil
			}
		}
		
		@objc func updateTribe() {
			DispatchQueue.main.async {
				self.tribes = TribesRepository.shared.getTribes()
			}
		}
	}
}
