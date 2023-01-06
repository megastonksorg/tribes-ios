//
//  HomeView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-06.
//

import SwiftUI

struct HomeView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		TabView {
			ComposeView(viewModel: viewModel.composeVM)
			VStack {
				Text("Tribes")
				Spacer()
			}
			.pushOutFrame()
			.background(Color.app.background)
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
		.ignoresSafeArea()
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(viewModel: .init())
	}
}
