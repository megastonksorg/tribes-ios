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
		
		enum Page: Int {
			case compose
			case tribes
		}
		
		@Published var composeVM: ComposeView.ViewModel = ComposeView.ViewModel()
		
		var currentPage: Page = .tribes {
			didSet {
				pageUpdated(page: currentPage)
			}
		}
		
		var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		init() {
			
		}
		
		func pageUpdated(page: Page) {
			switch page {
			case .compose: return
			case .tribes:
				self.composeVM.cameraVM.didDisappear()
			}
		}
		
		func didNotCompletePageScroll() {
			switch currentPage {
			case .compose: return
			case .tribes:
				self.composeVM.cameraVM.didDisappear()
			}
		}
	}
}
