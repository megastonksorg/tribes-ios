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
		
		var isCreateButtonEnabled: Bool {
			!name.isEmpty
		}
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		
		func createTribe() {
			apiClient.createTribe(name: name)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						switch completion {
							case .finished: return
							case .failure(let error):
							self?.banner = BannerData(error: error)
						}
					},
					receiveValue: { _ in
						AppRouter.popStack(stack: .home(.createTribe))
					}
				)
				.store(in: &cancellables)
		}
		
		func setName(_ name: String) {
			guard name.isTribeNameValid else { return }
			self.name = name
		}
	}
}
