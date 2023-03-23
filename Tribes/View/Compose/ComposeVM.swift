//
//  ComposeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import Combine
import Foundation

extension ComposeView {
	@MainActor class ViewModel: ObservableObject {
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var cameraVM: CameraView.ViewModel = CameraView.ViewModel()
		@Published var draftVM: DraftView.ViewModel
		@Published var allowedRecipients: Set<Tribe.ID> = []
		
		var hasContentBeenCaptured: Bool {
			draftVM.content != nil
		}
		
		//Clients
		private let apiClient: APIClient = APIClient.shared
		
		init() {
			self.draftVM = DraftView.ViewModel()
			cameraVM.$capturedImage
				.sink(receiveValue: { [weak self] image in
					guard
						let image = image,
						let imageData = image.pngData()
					else { return }
					self?.draftVM.setContent(content: .imageData(imageData))
				})
				.store(in: &cancellables)
			
			cameraVM.$capturedVideo
				.sink(receiveValue: { [weak self] url in
					guard let url = url else { return }
					self?.draftVM.setContent(content: .video(url))
				})
				.store(in: &cancellables)
			
			$allowedRecipients
				.sink(receiveValue: { [weak self] recipients in
					self?.draftVM.setAllowedRecipients(recipients)
				})
				.store(in: &cancellables)
			
			addObservers()
			fetchAllowedTeaRecipients()
		}
		
		func setDraftRecipient(_ directRecipient: Tribe?) {
			self.draftVM.directRecipient = directRecipient
		}
		
		private func addObservers() {
			cameraVM
				.objectWillChange
				.sink(receiveValue: { [weak self] in
					self?.objectWillChange.send()
				})
				.store(in: &cancellables)
			draftVM
				.objectWillChange
				.sink(receiveValue: { [weak self] in
					self?.objectWillChange.send()
				})
				.store(in: &cancellables)
		}
		
		private func fetchAllowedTeaRecipients() {
			self.apiClient
				.getAllowedTeaRecipients()
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { [weak self] tribeIds in
						guard let self = self else { return }
						self.allowedRecipients = Set(tribeIds)
					}
				)
				.store(in: &cancellables)
		}
	}
}
