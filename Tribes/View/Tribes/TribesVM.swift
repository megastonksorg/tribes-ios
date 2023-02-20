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
		@Published var leaveTribeVM: LeaveTribeView.ViewModel?
		@Published var tribeInviteVM: TribeInviteView.ViewModel?
		@Published var focusedTribe: Tribe?
		@Published var tribes: IdentifiedArrayOf<Tribe>
		@Published var editTribeNameText: String?
		@Published var user: User
		
		@Published var isShowingAccountView: Bool = false
		@Published var isShowingTribeInvite: Bool = false
		@Published var isShowingTribeTea: Bool = false
		
		var isEditingTribeName: Bool {
			editTribeNameText != nil
		}
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		private let feedbackClient: FeedbackClient = FeedbackClient.shared
		private let tribesRepository: TribesRepository = TribesRepository.shared
		
		init(tribes: IdentifiedArrayOf<Tribe> = TribesRepository.shared.getTribes(), user: User) {
			self.accountVM = AccountView.ViewModel(user: user)
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
		
		func toggleAccountView() {
			if !self.isShowingAccountView {
				self.accountVM = AccountView.ViewModel(user: self.user)
			}
			self.isShowingAccountView.toggle()
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
			if let text = text {
				if text.isTribeNameValid {
					self.editTribeNameText = text
					return
				} else {
					return
				}
			} else {
				self.editTribeNameText = text
			}
		}
		
		func updateTribeName() {
			guard
				let focusedTribe = self.focusedTribe,
				let newTribeName = self.editTribeNameText?.trimmingCharacters(in: .whitespacesAndNewlines),
				newTribeName.count > 0,
				newTribeName != focusedTribe.name
			else {
				self.editTribeNameText = nil
				return
			}
			let updatedTribe: Tribe = Tribe(
				id: focusedTribe.id,
				name: newTribeName,
				timestampId: focusedTribe.timestampId,
				members: focusedTribe.members
			)
			
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
		
		func setIsShowingTribeTea(_ isShowing: Bool) {
			withAnimation(.easeInOut.speed(2.0)) {
				self.isShowingTribeTea = isShowing
			}
		}
		
		func setLeaveTribeVM(_ viewModel: LeaveTribeView.ViewModel?) {
			self.leaveTribeVM = viewModel
		}
		
		func tribeLeaveActionTapped(_ tribe: Tribe) {
			setFocusedTribe(nil)
			setLeaveTribeVM(LeaveTribeView.ViewModel(tribe: tribe))
		}
		
		func tribeDoubleTapped(_ tribe: Tribe) {
			NotificationCenter.default.post(Notification(name: .openCompose))
		}
		
		func tribePrimaryActionTapped(_ tribe: Tribe) {
			if focusedTribe == nil {
				if tribe.members.count == 1 {
					showTribeInviteCard(tribe: tribe)
				} else {
					setIsShowingTribeTea(true)
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
