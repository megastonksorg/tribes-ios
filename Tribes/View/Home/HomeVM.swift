//
//  HomeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-06.
//

import Foundation
import Combine

extension HomeView {
	@MainActor class ViewModel: ObservableObject {
		
		enum Page: CaseIterable, Hashable {
			case compose
			case tribes
		}
		
		@Published var composeVM: ComposeView.ViewModel = ComposeView.ViewModel()
		
		@Published var currentPage: Page = .tribes
		
		var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		init() {
			$currentPage
				.sink(receiveValue: { [weak self] page in
					switch page {
					case .compose:
						self?.composeVM.cameraVM.didAppear()
					case .tribes:
						self?.composeVM.cameraVM.didDisappear()
					}
				})
				.store(in: &cancellables)
		}
	}
}
