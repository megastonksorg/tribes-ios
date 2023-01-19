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
			currentPage: Binding(
				get: { viewModel.currentPage.rawValue },
				set: { viewModel.currentPage = ViewModel.Page(rawValue: $0)! }
			),
			didNotCompleteScroll: { viewModel.didNotCompletePageScroll() }
		) {
			[
				HomeContentView(page: .compose, viewModel: viewModel),
				HomeContentView(page: .tribes, viewModel: viewModel)
			]
		}
		.ignoresSafeArea()
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(viewModel: .init(user: User.noop))
	}
}
