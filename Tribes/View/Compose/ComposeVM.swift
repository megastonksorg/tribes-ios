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
			cameraVM.capturedImage != nil
		}
		
		init() {
			cameraVM.$capturedImage
				.sink(receiveValue: { image in
					guard let image = image else { return }
					self.draftVM.contentVM = .init(image: image)
				})
				.store(in: &cancellables)
		}
	}
}
