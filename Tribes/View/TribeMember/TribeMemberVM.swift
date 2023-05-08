//
//  TribeMemberVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-07.
//

import Combine
import Foundation

extension TribeMemberView {
	@MainActor class ViewModel: ObservableObject {
		let member: TribeMember
		let tribe: Tribe
		let didCompleteAction: () -> ()
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var isProcessingRequest: Bool = false
		@Published var isShowingBlockRequest: Bool = false
		@Published var isShowingRemoveRequest: Bool = false
		@Published var banner: BannerData?
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		
		init(member: TribeMember, tribe: Tribe, didCompleteAction: @escaping () -> ()) {
			self.member = member
			self.tribe = tribe
			self.didCompleteAction = didCompleteAction
		}
		
		func requestToBlockTribeMember() {
			self.isShowingBlockRequest = true
		}
		
		func requestToRemoveTribeMember() {
			self.isShowingRemoveRequest = true
		}
		
		func blockTribeMember() {
			self.apiClient.blockMember(tribeID: tribe.id, memberId: member.id)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
						case .finished:
							self?.isProcessingRequest = false
						case .failure(let error):
							self?.isProcessingRequest = false
							self?.banner = BannerData(error: error)
						}
					},
					receiveValue: { [weak self] _ in
						guard let self = self else { return }
						self.didCompleteAction()
					}
				)
				.store(in: &cancellables)
		}
		
		func removeTribeMember() {
			self.apiClient.removeMember(tribeID: tribe.id, memberId: member.id)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
						case .finished:
							self?.isProcessingRequest = false
						case .failure(let error):
							self?.isProcessingRequest = false
							self?.banner = BannerData(error: error)
						}
					},
					receiveValue: { [weak self] _ in
						guard let self = self else { return }
						self.didCompleteAction()
					}
				)
				.store(in: &cancellables)
		}
	}
}
