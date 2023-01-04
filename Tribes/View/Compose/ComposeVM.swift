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
		@Published var draftVM: DraftView.ViewModel = DraftView.ViewModel()
		
		var hasContentBeenCaptured: Bool {
			draftVM.teaContentVM != nil
		}
		
		init() {
			cameraVM.$capturedImage
				.sink(receiveValue: { [weak self] image in
					guard let image = image else { return }
					self?.draftVM.setTeaContent(content: .image(image))
				})
				.store(in: &cancellables)
			
			cameraVM.$capturedVideo
				.sink(receiveValue: { [weak self] url in
					guard let url = url else { return }
					self?.draftVM.setTeaContent(content: .video(url))
				})
				.store(in: &cancellables)
			
			addObservers()
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
	}
}
