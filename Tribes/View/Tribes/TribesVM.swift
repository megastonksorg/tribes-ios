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
		
		private let apiClient: APIClient = APIClient.shared
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var banner: BannerData?
		@Published var tribeInviteVM: TribeInviteView.ViewModel?
		@Published var tribes: IdentifiedArrayOf<Tribe>
		@Published var user: User
		
		@Published var isShowingTribeInvite: Bool = false
		
		init(tribes: IdentifiedArrayOf<Tribe> = [], user: User) {
			self.tribes = tribes
			self.user = user
		}
		
		func createTribe() {
			AppRouter.pushStack(stack: .home(.createTribe))
		}
		
		func joinTribe() {
			AppRouter.pushStack(stack: .home(.joinTribe))
		}
		
		func loadTribes() {
			apiClient.getTribes()
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
						self?.tribes = IdentifiedArray(uniqueElements: tribes)
					}
				)
				.store(in: &cancellables)
		}
		
		func tribePrimaryActionTapped(_ tribe: Tribe) {
			if tribe.members.count == 1 {
				showTribeInviteCard(tribe: tribe)
			}
		}
		
		func tribeSecondaryActionTapped(_ tribe: Tribe) {
			if tribe.members.count == 1 {
				showTribeInviteCard(tribe: tribe)
			}
		}
		
		func tribeInviteActionTapped(_ tribe: Tribe) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
				self.showTribeInviteCard(tribe: tribe)
			}
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
	}
}
