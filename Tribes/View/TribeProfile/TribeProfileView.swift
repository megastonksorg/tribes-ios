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
				HStack {
					Spacer()
					Button(action: {}) {
						Text("Cancel")
							.font(Font.app.title2)
							.foregroundColor(Color.white)
					}
				}
				.padding(.horizontal)
				ScrollView {
					VStack {
						let tribeAvatarSize: CGFloat = 200
						let padding: CGFloat = 20
						
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
						.padding(.horizontal, 20)
						
						HStack(spacing: 10) {
							Spacer()
							actionButton(action: {}) {
								VStack {
									Image(systemName: "person.fill.badge.plus")
										.font(.system(size: FontSizes.title3))
									Text("Invite")
								}
							}
							.disabled(viewModel.tribe.members.count >= 10)
							Spacer()
							actionButton(action: {}) {
								VStack {
									Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
										.font(.system(size: FontSizes.body))
									Text("Leave")
								}
							}
							Spacer()
						}
						.font(.system(size: FontSizes.body))
						.foregroundColor(Color.white)
						.padding(.horizontal, padding)
						.padding(.vertical, padding / 1.5)
						.padding(.horizontal)
						.transition(.asymmetric(insertion: .scale, removal: .identity))
						.opacity(viewModel.isEditingTribeName ? 0.0 : 1.0)
						.animation(.easeInOut, value: viewModel.isEditingTribeName)
						
						VStack {
							ForEach(viewModel.tribe.members.others) {
								memberRow(member: $0)
							}
						}
						
						Spacer()
					}
				}
				.padding(.leading)
			}
			.pushOutFrame()
			.background(Color.app.background)
			.overlay(isShown: viewModel.isLoading) {
				AppProgressView()
			}
		}
	}
	
	@ViewBuilder
	func actionButton<Label: View>(action: @escaping () -> (), label: @escaping () -> Label) -> some View {
		Button(action: { action() }) {
			label()
				.frame(width: 100, height: 60)
				.background(Color.app.secondary, in: Capsule())
		}
	}
	
	@ViewBuilder
	func memberRow(member: TribeMember) -> some View {
		let avatarSize: CGFloat = 40
		let tintColor: Color = Color.gray.opacity(0.5)
		Button(action: {}) {
			VStack(spacing: 4) {
				HStack(spacing: 10) {
					UserAvatar(url: member.profilePhoto)
						.frame(dimension: avatarSize)
					Text(member.fullName)
						.font(Font.body)
						.foregroundColor(Color.white)
					Spacer()
					Image(systemName: "chevron.right")
						.font(.system(size: FontSizes.title2, weight: .medium))
						.foregroundColor(tintColor)
						.padding(.trailing, 4)
				}
				HStack {
					Rectangle()
						.fill(Color.clear)
						.frame(width: avatarSize)
					Rectangle()
						.fill(tintColor)
						.frame(height: 0.5)
				}
			}
		}
	}
}

struct TribeProfile_Previews: PreviewProvider {
	static var previews: some View {
		TribeProfileView(viewModel: .init(tribe: Tribe.noop2))
	}
}
