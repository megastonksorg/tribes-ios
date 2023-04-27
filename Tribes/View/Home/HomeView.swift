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
	
	@EnvironmentObject var appRouter: AppRouter
	
	@State var currentPageIndex: Int
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
		self._currentPageIndex = State(wrappedValue: viewModel.currentPage.rawValue)
	}
	
	var body: some View {
		NavigationStack(path: $appRouter.homeStack) {
			PageView(
				currentPage: $currentPageIndex,
				didNotCompleteScroll: { viewModel.didNotCompletePageScroll() }
			) {
				[
					HomeContentView(page: .compose, viewModel: viewModel),
					HomeContentView(page: .tribes, viewModel: viewModel)
				]
			}
			.ignoresSafeArea()
			.navigationTitle("")
			.navigationDestination(for: AppRouter.Route.HomeStack.self) { stack in
				Group {
					switch stack {
					case .createTribe:
						CreateTribeView(viewModel: CreateTribeView.ViewModel())
					case .joinTribe:
						JoinTribeView(viewModel: JoinTribeView.ViewModel())
					case .chat(tribeId: let tribeId):
						ChatView(viewModel: ChatView.ViewModel(tribeId: tribeId))
					}
				}
				.navigationBarTitleDisplayMode(.inline)
			}
			.onChange(of: currentPageIndex) { pageIndex in
				viewModel.setCurrentPage(page: ViewModel.Page(rawValue: pageIndex)!)
			}
			.onChange(of: viewModel.currentPage) { currentPage in
				if currentPageIndex != currentPage.rawValue {
					self.currentPageIndex = currentPage.rawValue
				}
			}
		}
		.tint(Color.app.secondary)
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(viewModel: .init(user: User.noop))
			.environmentObject(AppRouter())
	}
}
