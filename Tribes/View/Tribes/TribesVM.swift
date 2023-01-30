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
		
		func openTribeInvite() {
			self.tribeInviteVM = TribeInviteView.ViewModel(tribe: Tribe.noop)
		}
		
		func closeTribeInvite() {
			self.tribeInviteVM = nil
		}
		
		func testGetTribe() {
			apiClient.getTribes()
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
							case .finished: return
							case .failure(let error):
							DispatchQueue.main.async {
								self?.banner = BannerData(error: error)
							}
						}
					},
					receiveValue: { [weak self] tribes in
						self?.banner = BannerData(title: "YES", detail: "SUCCESS", type: .success)
					}
				)
				.store(in: &cancellables)
		}
	}
}
