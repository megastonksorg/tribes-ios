//
//  LeaveTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-02.
//

import Combine
import Foundation

extension LeaveTribeView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
		  case confirmation
		}
		
		static let confirmationTitle: String = "Leave"
		let tribe: Tribe
		let tribeMembers: [TribeMember]
		
		var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		var isConfirmed: Bool {
			confirmation == ViewModel.confirmationTitle
		}
		
		@Published var confirmation: String = ""
		@Published var didLeaveTribe: Bool = false
		@Published var isLoading: Bool = false
		@Published var banner: BannerData?
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		
		init(tribe: Tribe) {
			self.tribeMembers = tribe.members.others
			self.tribe = tribe
		}
		
		func leaveTribe() {
			self.isLoading = true
			self.apiClient
				.leaveTribe(tribeID: tribe.id)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
						case .finished: return
						case .failure(let error):
							self?.isLoading = false
							self?.banner = BannerData(error: error)
						}
					}, receiveValue: { [weak self] successResponse in
						self?.isLoading = false
						self?.didLeaveTribe = successResponse.success
					}
				)
				.store(in: &self.cancellables)
		}
	}
}
