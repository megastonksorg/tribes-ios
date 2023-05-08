//
//  TribeProfileVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-07.
//

import Combine
import Foundation
import SwiftUI

extension TribeProfileView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: String, Hashable, Identifiable {
			case editTribeName
			
			var id: String { self.rawValue }
		}
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var tribe: Tribe
		@Published var editTribeNameText: String
		@Published var isEditingTribeName: Bool = false
		@Published var isLoading: Bool = false
		@Published var isShowingTribeInvite: Bool = false
		
		@Published var banner: BannerData?
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		private let tribesRepository: TribesRepository = TribesRepository.shared
		
		init(tribe: Tribe) {
			self.editTribeNameText = tribe.name
			self.tribe = tribe
			
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(updateTribe),
					name: .tribesUpdated,
					object: nil
				)
		}
		
		func dismissTribeInviteCard() {
			withAnimation(Animation.cardViewDisappear) {
				self.isShowingTribeInvite = false
			}
		}
		
		func editTribeName() {
			self.isEditingTribeName = true
		}
		
		func setEditTribeNameText(_ text: String) {
			if text.count <= SizeConstants.tribeNameLimit {
				self.editTribeNameText = text
				return
			} else {
				return
			}
		}
		
		func inviteTapped() {
			withAnimation(Animation.cardViewAppear) {
				self.isShowingTribeInvite = true
			}
		}
		
		func resetEditTribeName() {
			self.editTribeNameText = self.tribe.name
		}
		
		func showTribeInviteCopyBanner() {
			self.banner = BannerData(detail: "Pin Code copied to clipboard", type: .success)
		}
		
		func updateTribeName() {
			self.isEditingTribeName = false
			self.isLoading = true
			
			let newTribeName = self.editTribeNameText.trimmingCharacters(in: .whitespacesAndNewlines)
			
			guard
				newTribeName.isTribeNameValid,
				newTribeName != tribe.name
			else {
				self.editTribeNameText = tribe.name
				self.isLoading = false
				return
			}
			
			self.apiClient.updateTribeName(tribeID: tribe.id, name: newTribeName)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
							case .finished: return
							case .failure(let error):
							self?.isLoading = false
							self?.banner = BannerData(error: error)
						}
					},
					receiveValue: { [weak self] newTribeName in
						guard let self = self else { return }
						let updatedTribe: Tribe = Tribe(
							id: self.tribe.id,
							name: newTribeName,
							timestampId: self.tribe.timestampId,
							members: self.tribe.members
						)
						self.tribe = updatedTribe
						self.isLoading = false
						//Notify the repository that the Tribe has been updated
					}
				)
				.store(in: &cancellables)
		}
		
		@objc func updateTribe() {
			DispatchQueue.main.async {
				if let tribe = self.tribesRepository.getTribe(tribeId: self.tribe.id) {
					self.tribe = tribe
				}
			}
		}
	}
}
