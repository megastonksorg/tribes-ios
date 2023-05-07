//
//  TribeProfileVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-07.
//

import Combine
import Foundation

extension TribeProfileView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: String, Hashable, Identifiable {
			case editTribeName
			
			var id: String { self.rawValue }
		}
		enum Stack: Hashable {
			case userProfile
		}
		
		let tribe: Tribe
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var editTribeNameText: String
		@Published var stack: [Stack] = []
		@Published var isEditingTribeName: Bool = false
		
		@Published var banner: BannerData?
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		private let tribesRepository: TribesRepository = TribesRepository.shared
		
		init(tribe: Tribe) {
			self.editTribeNameText = tribe.name
			self.tribe = tribe
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
		
		func resetEditTribeName() {
			self.editTribeNameText = self.tribe.name
		}
		
		func updateTribeName() {
			let newTribeName = self.editTribeNameText.trimmingCharacters(in: .whitespacesAndNewlines)
			
			guard
				newTribeName.isTribeNameValid,
				newTribeName != tribe.name
			else {
				self.editTribeNameText = tribe.name
				return
			}
			
			self.apiClient.updateTribeName(tribeID: tribe.id, name: newTribeName)
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
						//Notify everyone that the Tribe has been updated
					}
				)
				.store(in: &cancellables)
		}
	}
}
