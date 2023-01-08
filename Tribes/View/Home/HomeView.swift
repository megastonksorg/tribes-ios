//
//  HomeView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-06.
//

import Introspect
import SwiftUI

struct HomeView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		PageView(
			selection:  $viewModel.currentPage,
			content: {
				[
					HomeContentView(page: .compose, viewModel: viewModel),
					HomeContentView(page: .tribes, viewModel: viewModel)
				]
			}
		)
		.ignoresSafeArea()
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(viewModel: .init())
	}
}

extension PageView {
	init(selection: Binding<HomeView.ViewModel.Page>, content: @escaping () -> [Content]) {
		self.init(
			selection: Binding<Int>(
				get: { HomeView.ViewModel.Page.allCases.firstIndex(of: selection.wrappedValue)! },
				set: { selection.wrappedValue = HomeView.ViewModel.Page.allCases[$0] }
			),
			content: content
		)
	}
}
