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
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		NavigationStack(
			path: Binding(
				get: { appRouter.homeStack },
				set: { appRouter.setHomeStack($0) }
			)
		) {
			TribesView(viewModel: viewModel.tribesVM)
				.fullScreenCover(isPresented: $viewModel.isShowingCompose) {
					ComposeView(viewModel: viewModel.composeVM)
				}
				.navigationTitle("")
				.navigationDestination(for: AppRouter.Route.HomeStack.self) { stack in
					Group {
						switch stack {
						case .createTribe:
							CreateTribeView(viewModel: CreateTribeView.ViewModel())
						case .joinTribe:
							JoinTribeView(viewModel: JoinTribeView.ViewModel())
						case .chat(tribe: let tribe):
							ChatView(viewModel: ChatView.ViewModel(tribe: tribe))
						}
					}
					.navigationBarTitleDisplayMode(.inline)
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
