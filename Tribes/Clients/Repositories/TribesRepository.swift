//
//  TribesRepository.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-09.
//

import Combine
import Foundation
import IdentifiedCollections

protocol TribesRepositoryProtocol {
	func getTribes() -> IdentifiedArrayOf<Tribe>
}

class TribesRepository: TribesRepositoryProtocol {
	static let shared: TribesRepository = TribesRepository()
	
	private let queue = DispatchQueue(label: "com.strikingFinancial.tribes.tribesRepository.sessionQueue", target: .global())
	
	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	
	var tribes: IdentifiedArrayOf<Tribe> = []
	
	//Clients
	private let apiClient: APIClient = APIClient.shared
	private let cacheClient: CacheClient = CacheClient.shared
	
	init() {
		Task { [weak self] in
			let cachedTribes = await cacheClient.getData(key: .tribes)
			guard let cachedTribes = cachedTribes else { return }
			self?.tribes = cachedTribes
		}
	}
	
	func getTribes() -> IdentifiedArrayOf<Tribe> {
		return tribes
	}
	
	func refreshTribes() -> Future<IdentifiedArrayOf<Tribe>, APIClientError> {
		return Future { [weak self] promise in
			guard let self = self else { return }
			self.apiClient.getTribes()
				.sink(
					receiveCompletion: { completion in
						switch completion {
							case .finished: return
							case .failure(let error):
							promise(.failure(error))
						}
					},
					receiveValue: { tribes in
						let tribes = IdentifiedArray(uniqueElements: tribes)
						self.queue.sync {
							self.tribes = tribes
						}
						Task {
							await self.cacheClient.setData(key: .tribes, value: tribes)
						}
						promise(.success(tribes))
					}
				)
				.store(in: &self.cancellables)
		}
	}
}
