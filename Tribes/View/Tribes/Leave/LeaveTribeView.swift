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
			VStack {
				SymmetricHStack(
					content: {
						Text("\(ViewModel.confirmationTitle)?")
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
				
				VStack(spacing: 20) {
					Text("Are you sure you want to \(ViewModel.confirmationTitle) ‘\(viewModel.tribe.name)’ tribe?")
					Text("If you are sure, please type")
					+
					Text(" \(ViewModel.confirmationTitle) ")
						.foregroundColor(Color.app.tertiary)
						.bold()
					+
					Text("below")
				}
				.multilineTextAlignment(.center)
				.font(Font.app.title2)
				.foregroundColor(.white)
				.padding(.top)
				
				SymmetricHStack(
					content: {
						VStack {
							ZStack {
								Text("\(ViewModel.confirmationTitle)")
									.foregroundColor(Color.gray.opacity(viewModel.confirmation.isEmpty ? 0.4 : 0.0))
								TextField("", text: $viewModel.confirmation)
								.tint(Color.app.tertiary)
								.focused($focusedField, equals: .confirmation)
								.keyboardType(.asciiCapable)
								.multilineTextAlignment(.center)
							}
						}
						.onAppear { self.focusedField = .confirmation }
					},
					leading: {
						Image(systemName: "exclamationmark.circle.fill")
							
					},
					trailing: { EmptyView() }
				)
				.font(.system(size: FontSizes.title1, weight: .semibold, design: .rounded))
				.foregroundColor(Color.app.tertiary)
				.padding(.top, 40)
				.padding(.horizontal)
			}
			.padding(.horizontal)
			
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
