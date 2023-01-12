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
			VStack {
				SymmetricHStack(
					content: {
						TextView("Tribes", style: .appTitle)
					},
					leading: {
						Button(action: {}) {
							Circle()
								.fill(Color.gray)
								.frame(dimension: 50)
						}
						.buttonStyle(.insideScaling)
					},
					trailing: {
						Button(action: {}) {
							Image(systemName: "plus.circle.fill")
								.font(.system(size: 30))
								.foregroundColor(Color.app.secondary)
						}
						.buttonStyle(.insideScaling)
					}
				)
				.padding(.horizontal)
				
				Spacer()
			}
			.pushOutFrame()
			.background(Color.app.background)
		}
	}
}

struct HomeContentView_Previews: PreviewProvider {
	static var previews: some View {
		HomeContentView(page: .tribes, viewModel: .init())
	}
}
