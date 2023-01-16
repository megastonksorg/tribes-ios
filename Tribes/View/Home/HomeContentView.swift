//
//  HomeContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-07.
//

import SwiftUI

struct HomeContentView: View {
	let page: HomeView.ViewModel.Page
	
	@StateObject var viewModel: HomeView.ViewModel
	
	init(page: HomeView.ViewModel.Page, viewModel: HomeView.ViewModel) {
		self.page = page
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		switch page {
		case .compose:
			ComposeView(viewModel: viewModel.composeVM)
		case .tribes:
			TribesView(viewModel: viewModel.tribesVM)
		}
	}
}

struct HomeContentView_Previews: PreviewProvider {
	static var previews: some View {
		HomeContentView(page: .tribes, viewModel: .init())
	}
}
