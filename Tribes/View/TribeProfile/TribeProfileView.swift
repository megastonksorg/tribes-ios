//
//  TribeProfileView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-07.
//

import SwiftUI

struct TribeProfileView: View {
	@StateObject var viewModel: ViewModel
	
	@FocusState private var focusedField: ViewModel.FocusField?
	
	var body: some View {
		NavigationStack(path: $viewModel.stack) {
			VStack {
				let tribeAvatarSize: CGFloat = 200
				HStack {
					Spacer()
					Button(action: {}) {
						Text("Cancel")
							.font(Font.app.title2)
							.foregroundColor(Color.white)
					}
				}
				.padding(.horizontal)
				
				TribeAvatar(
					context: .profileView,
					tribe: viewModel.tribe,
					size: tribeAvatarSize,
					primaryAction: { _ in },
					secondaryAction: { _ in }
				)
				.disabled(true)
				
				ZStack {
					let fontSize: CGFloat =  tribeAvatarSize.getTribeNameSize() + 4
					
					TribeNameView(name: viewModel.tribe.name, shouldShowEditIcon: true, fontSize: fontSize) {
						viewModel.editTribeName()
					}
					.opacity(viewModel.isEditingTribeName ? 0.0 : 1.0)
					
					if viewModel.isEditingTribeName {
						TextField("", text: $viewModel.editTribeNameText)
							.disableAutoCorrection(isNameField: false)
							.submitLabel(.done)
							.onSubmit { viewModel.updateTribeName() }
							.font(.system(size: fontSize, weight: .medium, design: .rounded))
							.foregroundColor(Color.app.tertiary)
							.multilineTextAlignment(.center)
							.focused($focusedField, equals: .editTribeName)
							.onAppear { self.focusedField = .editTribeName }
							.onAppear { self.focusedField = nil }
					}
				}
				.padding(.top)
				.padding(.horizontal, 20)
				Spacer()
			}
			.pushOutFrame()
			.background(Color.app.background)
		}
	}
}

struct TribeProfile_Previews: PreviewProvider {
	static var previews: some View {
		TribeProfileView(viewModel: .init(tribe: Tribe.noop2))
	}
}
