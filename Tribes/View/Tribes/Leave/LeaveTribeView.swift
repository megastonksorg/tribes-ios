//
//  LeaveTribeView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-02.
//

import SwiftUI

struct LeaveTribeView: View {
	@FocusState private var focusedField: ViewModel.FocusField?
	
	@State var avatarsWidth: CGFloat = 0
	@StateObject var viewModel: ViewModel
	
	@Environment(\.dismiss) var dismiss
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			VStack {
				SymmetricHStack(
					content: {
						Text("\(ViewModel.confirmationTitle)?")
					},
					leading: { EmptyView() },
					trailing: {
						Button(action: { dismiss() }) {
							Image(systemName: "xmark")
						}
					}
				)
				.font(Font.app.title2)
				.fontWeight(.semibold)
				.foregroundColor(Color.app.tertiary)
				.padding(.top)
				
				Text("Are you sure you want to \(ViewModel.confirmationTitle) ‘\(viewModel.tribe.name)’?")
					.fixedSize(horizontal: false, vertical: true)
					.padding(.top)
				
				ScrollView(.horizontal) {
					LazyHStack(spacing: 10) {
						ForEach(viewModel.tribeMembers) {
							userAvatar(user: $0)
						}
					}
					.readSize { size in
						let maxWidth = UIScreen.main.bounds.maxX * 0.8
						if size.width < maxWidth {
							self.avatarsWidth = size.width
						} else {
							self.avatarsWidth = maxWidth
						}
					}
				}
				.frame(width: self.avatarsWidth, height: 100, alignment: .center)
				.padding(.top)
				
				Text("Type")
				+
				Text(" \(ViewModel.confirmationTitle) ")
					.foregroundColor(Color.app.tertiary)
					.bold()
				+
				Text("below")
				
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
				.padding(.top)
				.padding(.horizontal)
				
				Spacer()
				
				Button(action: { viewModel.leaveTribe() }) {
					Text(ViewModel.confirmationTitle)
				}
				.buttonStyle(.expanded)
				.disabled(!viewModel.isConfirmed)
				.padding(.bottom)
				.padding(.bottom)
				.ignoresSafeArea(.keyboard)
			}
			.padding(.horizontal)
			.onChange(of: viewModel.didLeaveTribe) { _ in
				dismiss()
			}
		}
		.multilineTextAlignment(.center)
		.font(Font.app.subTitle)
		.foregroundColor(.white)
		.pushOutFrame()
		.overlay(isShown: viewModel.isLoading) {
			AppProgressView()
		}
		.banner(data: self.$viewModel.banner)
		.background(Color.app.background)
	}
	
	@ViewBuilder
	func userAvatar(user: TribeMember) -> some View {
		VStack {
			UserAvatar(url: user.profilePhoto)
				.frame(dimension: 50)
			Text(user.fullName)
				.font(Font.app.subTitle)
				.foregroundColor(Color.white)
		}
	}
}

struct LeaveTribeView_Previews: PreviewProvider {
	static var previews: some View {
		LeaveTribeView(viewModel: .init(tribe: Tribe.noop2))
	}
}
