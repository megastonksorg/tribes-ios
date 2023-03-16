//
//  CreateTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-23.
//

import Combine
import Foundation

extension CreateTribeView {
	@MainActor class ViewModel: ObservableObject {
		enum Field: Hashable {
			case name
		}
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var banner: BannerData?
		@Published var name: String = ""
		
		@Published var isLoading: Bool = false
		
		var isCreateButtonEnabled: Bool {
			name.isTribeNameValid
		}
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		
		func createTribe() {
			self.isLoading = true
			apiClient.createTribe(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
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
					receiveValue: { _ in
						self.isLoading = false
						AppRouter.popStack(stack: .home(.createTribe))
					}
				)
				.store(in: &cancellables)
		}
		
		func setName(_ name: String) {
			guard name.count <= SizeConstants.tribeNameLimit else { return }
			self.name = name
		}
	}
}
