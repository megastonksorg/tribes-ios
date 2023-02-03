//
//  LeaveTribeView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-02.
//

import SwiftUI

struct LeaveTribeView: View {
	@FocusState private var focusedField: ViewModel.FocusField?
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack(spacing: 20) {
			SymmetricHStack(
				content: {
					Text("Leave?")
				},
				leading: { EmptyView() },
				trailing: {
					Button(action: {}) {
						Image(systemName: "xmark")
					}
				}
			)
			.font(Font.app.title2)
			.fontWeight(.semibold)
			.foregroundColor(Color.app.tertiary)
			.padding(.horizontal)
			
			VStack(spacing: 20) {
				Text("Are you sure you want to leave ‘\(viewModel.tribe.name)’ tribe?")
				Text("If you are sure, please type")
				+
				Text(" Leave ")
					.foregroundColor(Color.app.tertiary)
					.bold()
				+
				Text("below")
			}
			.multilineTextAlignment(.center)
			.font(Font.app.title2)
			.foregroundColor(.white)
			.padding(.top)
			
			Spacer()
		}
		.pushOutFrame()
		.overlay(isShown: viewModel.isLoading) {
			AppProgressView()
		}
		.banner(data: self.$viewModel.banner)
		.background(Color.app.background)
	}
}

struct LeaveTribeView_Previews: PreviewProvider {
	static var previews: some View {
		LeaveTribeView(viewModel: .init(tribe: Tribe.noop))
	}
}
