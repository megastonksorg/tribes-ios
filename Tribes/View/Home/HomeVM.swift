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
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var composeVM: ComposeView.ViewModel = ComposeView.ViewModel()
		@Published var tribesVM: TribesView.ViewModel
		
		var currentPage: Page = .tribes {
			didSet {
				pageUpdated(page: currentPage)
			}
		}
		
		var user: User
		
		init(user: User) {
			self.user = user
			self.tribesVM = TribesView.ViewModel(user: user)
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
