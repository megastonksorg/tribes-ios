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
		@Published var leaveTribeVM: LeaveTribeView.ViewModel?
		@Published var tribeInviteVM: TribeInviteView.ViewModel?
		@Published var focusedTribe: Tribe?
		@Published var tribes: IdentifiedArrayOf<Tribe>
		@Published var editTribeNameText: String?
		@Published var user: User
		
		@Published var isShowingTribeInvite: Bool = false
		
		var isEditingTribeName: Bool {
			editTribeNameText != nil
		}
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		private let feedbackClient: FeedbackClient = FeedbackClient.shared
		private let tribesRepository: TribesRepository = TribesRepository.shared
		
		init(tribes: IdentifiedArrayOf<Tribe> = TribesRepository.shared.getTribes(), user: User) {
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
		
		func setFocusedTribe(_ tribe: Tribe?) {
			if tribe != nil {
				self.feedbackClient.medium()
			}
			withAnimation(.easeInOut.speed(1.4)) {
				self.focusedTribe = tribe
			}
		}
		
		func editTribeName() {
			self.editTribeNameText = focusedTribe?.name ?? ""
		}
		
		func setEditTribeNameText(_ text: String?) {
			self.editTribeNameText = text
		}
		
		func updateTribeName() {
			guard
				let focusedTribe = self.focusedTribe,
				let newTribeName = self.editTribeNameText?.trimmingCharacters(in: .whitespacesAndNewlines),
				newTribeName.count > 0
			else {
				self.editTribeNameText = nil
				return
			}
			let updatedTribe: Tribe = Tribe(id: focusedTribe.id, name: newTribeName, members: focusedTribe.members)
			
			self.focusedTribe = updatedTribe
			self.tribes[id: updatedTribe.id] = updatedTribe
			self.editTribeNameText = nil
			
			apiClient.updateTribeName(tribeID: focusedTribe.id, name: newTribeName)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
							case .finished: return
							case .failure(let error):
							self?.banner = BannerData(error: error)
						}
					},
					receiveValue: { [weak self] _ in
						self?.loadTribes()
					}
				)
				.store(in: &cancellables)
		}
		
		func setLeaveTribeVM(_ viewModel: LeaveTribeView.ViewModel?) {
			self.leaveTribeVM = viewModel
		}
		
		func tribeLeaveActionTapped(_ tribe: Tribe) {
			setFocusedTribe(nil)
			setLeaveTribeVM(LeaveTribeView.ViewModel(tribe: tribe))
		}
		
		func tribePrimaryActionTapped(_ tribe: Tribe) {
			if focusedTribe == nil {
				if tribe.members.count == 1 {
					showTribeInviteCard(tribe: tribe)
				}
			}
		}
		
		func tribeSecondaryActionTapped(_ tribe: Tribe) {
			
		}
		
		func tribeInviteActionTapped(_ tribe: Tribe) {
			setFocusedTribe(nil)
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
	}
}
