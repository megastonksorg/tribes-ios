//
//  HomeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-06.
//

import Foundation

extension HomeView {
	@MainActor class ViewModel: ObservableObject {
		@Published var composeVM: ComposeView.ViewModel = ComposeView.ViewModel()
		
		init() {
		}
	}
}
