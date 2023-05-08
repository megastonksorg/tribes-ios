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
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
			VStack {
				VStack(spacing: 2) {
					let tribeAvatarSize: CGFloat = 200
					
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
								.onDisappear { self.focusedField = nil }
						}
					}
					
					HStack(spacing: 10) {
						Spacer()
						Button(action: { viewModel.inviteTapped() }) {
							actionButtonView {
								VStack {
									Image(systemName: "person.fill.badge.plus")
										.font(.system(size: FontSizes.title3))
									Text("Invite")
								}
							}
						}
						.disabled(viewModel.tribe.members.count >= 10)
						Spacer()
						NavigationLink(
							destination: {
								LeaveTribeView(
									viewModel: LeaveTribeView.ViewModel(
										tribe: viewModel.tribe,
										didLeaveTribe: {
											dismiss()
											AppRouter.popStack(stack: .home(.chat(tribe: viewModel.tribe)))
										}
									)
								)
							}
						) {
							actionButtonView {
								VStack {
									Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
										.font(.system(size: FontSizes.body))
									Text("Leave")
								}
							}
						}
						Spacer()
					}
					.font(.system(size: FontSizes.callout))
					.foregroundColor(Color.white)
					.padding(.top)
					.transition(.asymmetric(insertion: .scale, removal: .identity))
					.opacity(viewModel.isEditingTribeName ? 0.0 : 1.0)
					.animation(.easeInOut, value: viewModel.isEditingTribeName)
				}
				ScrollView(showsIndicators: true) {
					VStack {
						if let currentMember = viewModel.tribe.members.currentMember {
							memberRow(member: currentMember, isCurrentMember: true)
								.opacity(0.5)
						}
						ForEach(viewModel.tribe.members.others) { member in
							NavigationLink(
								destination: {
									TribeMemberView(
										viewModel: TribeMemberView.ViewModel(
											member: member,
											tribe: viewModel.tribe,
											didCompleteAction: { dismiss() }
										)
									)
								}
							) {
								memberRow(member: member, isCurrentMember: false)
							}
						}
					}
				}
				.padding([.leading, .top])
				.opacity(viewModel.isEditingTribeName ? 0.0 : 1.0)
				Spacer()
			}
			.navigationBarTitleDisplayMode(.inline)
			.pushOutFrame()
			.background(Color.app.background)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: { dismiss() }) {
						Text("Cancel")
							.font(Font.app.title3)
							.foregroundColor(Color.white)
					}
				}
			}
			.overlay(isShown: viewModel.isLoading) {
				AppProgressView()
			}
			.cardView(
				isShowing: $viewModel.isShowingTribeInvite,
				dismissAction: { viewModel.dismissTribeInviteCard() }
			) {
				TribeInviteView(
					didCopyAction: { viewModel.showTribeInviteCopyBanner() },
					dismissAction: { viewModel.dismissTribeInviteCard() },
					viewModel: TribeInviteView.ViewModel(tribe: viewModel.tribe)
				)
			}
			.banner(data: self.$viewModel.banner)
	}
	
	@ViewBuilder
	func actionButtonView<Label: View>(label: @escaping () -> Label) -> some View {
		label()
			.frame(width: 80, height: 50)
			.background(Color.app.secondary, in: Capsule())
	}
	
	@ViewBuilder
	func memberRow(member: TribeMember, isCurrentMember: Bool) -> some View {
		let avatarSize: CGFloat = 40
		let tintColor: Color = Color.gray.opacity(0.5)
		VStack(spacing: 4) {
			HStack(spacing: 10) {
				UserAvatar(url: member.profilePhoto)
					.frame(dimension: avatarSize)
				Text(member.fullName)
					.font(Font.body)
					.foregroundColor(Color.white)
				Spacer()
				Group {
					if isCurrentMember {
						Text("(You)")
							.font(Font.app.body)
							.foregroundColor(tintColor)
					} else {
						Image(systemName: "chevron.right")
							.font(.system(size: FontSizes.title2, weight: .medium))
							.foregroundColor(tintColor)
					}
				}
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

struct TribeProfile_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			TribeProfileView(viewModel: .init(tribe: Tribe.noop2))
		}
	}
}
