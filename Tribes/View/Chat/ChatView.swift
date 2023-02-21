//
//  ChatView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import SwiftUI

struct ChatView: View {
	var dismissAction: () -> Void
	
	@FocusState private var focusedField: ViewModel.FocusField?
	
	@StateObject var viewModel: ViewModel
	
	@State var isShowingMemberImage: Bool = false
	
	init(viewModel: ViewModel, dismissAction: @escaping () -> Void) {
		self._viewModel = StateObject(wrappedValue: viewModel)
		self.dismissAction = dismissAction
	}
	var body: some View {
		VStack {
			VStack {
				Spacer()
				HStack(alignment: .bottom) {
					Button(
						action: {
							if self.focusedField == .text {
								self.focusedField = nil
							}
						}
					) {
						Image(systemName: self.focusedField == .text ? "keyboard.chevron.compact.down" : "camera.fill")
							.font(Font.app.title2)
							.foregroundColor(Color.gray.opacity(0.8))
					}
					.padding(.bottom, 4)
					ZStack(alignment: .leading) {
						Group {
							Text("Type a message to ")
								.foregroundColor(Color.gray)
							+
							Text(viewModel.tribe.name)
								.foregroundColor(Color.app.tertiary)
						}
						.opacity(viewModel.canSendText ? 0.0 : 1.0)
						TextField("", text: $viewModel.text, axis: .vertical)
							.tint(Color.white)
							.lineLimit(1...4)
							.foregroundColor(.white)
							.focused($focusedField, equals: .text)
					}
					.font(Font.app.body)
					.multilineTextAlignment(.leading)
					.padding(.leading, 4)
					.padding(.bottom, 6)
					Spacer()
					Button(
						action: {
							if viewModel.canSendText {
								
							} else {
								dismissAction()
							}
						}
					) {
						Image(systemName: viewModel.canSendText ? "paperplane.circle.fill" : "xmark.circle.fill")
							.font(.system(size: 30))
							.foregroundColor(Color.app.tertiary)
					}
				}
				.padding()
			}
			.background(
				CalloutRectangle(calloutRadius: 6, radius: 20)
					.stroke(
						LinearGradient(
							colors: [.clear, .clear, .clear, .clear, Color.app.secondary],
							startPoint: .top,
							endPoint: .bottom
						),
						lineWidth: 1.5
					)
			)
			.padding(.horizontal, 4)
			.offset(y: self.focusedField != .text ? -100 : 0)
			
			Spacer()
				.frame(height: 14)
		}
		.pushOutFrame()
		.background {
			VStack{
				Spacer()
				let tribeAvatarSize: CGFloat = 80
				HStack {
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack(alignment: .bottom) {
							ForEach(viewModel.tribe.members) { member in
								memberAvatar(member)
							}
						}
					}
					.frame(maxHeight: tribeAvatarSize + 20)
					.overlay(alignment: .trailing) {
						ZStack {
							LinearGradient(
								colors: [.black.opacity(0.2), .black.opacity(0.6), .black],
								startPoint: .leading,
								endPoint: .trailing
							)
							.blur(radius: 2)
							.frame(width: 30)
						}
						.offset(x: 4)
					}
					TribeAvatar(
						tribe: viewModel.tribe,
						size: tribeAvatarSize,
						avatarContextAction: { _ in dismissAction() },
						nameContextAction: { _ in dismissAction() },
						primaryAction: { _ in dismissAction() },
						secondaryAction: { _ in dismissAction() },
						inviteAction: { _ in },
						leaveAction: { _ in }
					)
				}
			}
			.padding(.horizontal)
			.ignoresSafeArea(.keyboard)
			.opacity(self.focusedField == .text ? 0.0 : 1.0)
		}
		.background(Color.app.background)
		.edgesIgnoringSafeArea(.top)
		.cardView(
			isShowing: $viewModel.isShowingMember,
			dismissAction: { viewModel.dismissTribeMemberCard() }
		) {
			Group {
				if let member = viewModel.memberToShow {
					memberCard(member)
				}
			}
		}
	}
	
	@ViewBuilder
	func memberAvatar(_ member: TribeMember) -> some View {
		Button(action: { viewModel.showTribeMemberCard(member) }) {
			VStack {
				Spacer()
				UserAvatar(url: member.profilePhoto)
					.frame(dimension: 55)
				Spacer()
				Text(member.fullName)
					.font(.system(size: FontSizes.footnote, weight: .semibold))
					.foregroundColor(Color.gray)
			}
		}
	}
	
	@ViewBuilder
	func memberCard(_ member: TribeMember) -> some View {
		VStack {
			SymmetricHStack(
				content: {
					TextView(member.fullName, style: .pageTitle)
				},
				leading: { EmptyView() },
				trailing: {
					XButton {
						viewModel.dismissTribeMemberCard()
					}
				}
			)
			.padding()
			UserAvatar(url: member.profilePhoto)
				.frame(dimension: 140)
				.opacity(self.isShowingMemberImage ? 1.0 : 0.0)
				.transition(.opacity)
			Spacer()
			Group {
				Text(member.fullName)
					.underline()
				+
				Text(" has been a member of this Tribe since \(member.joined)")
			}
			.font(Font.app.footnote)
			.foregroundColor(Color.gray)
			.padding(.bottom)
			Button(action: {}) {
				Text("Remove")
					.font(Font.app.title3)
					.textCase(.uppercase)
					.foregroundColor(Color.app.tertiary)
					.padding()
					.padding(.horizontal)
					.background(
						RoundedRectangle(cornerRadius: SizeConstants.secondaryCornerRadius)
							.stroke(Color.app.tertiary)
					)
					.fixedSize(horizontal: true, vertical: false)
			}
			.padding(.bottom)
		}
		.multilineTextAlignment(.center)
		.onAppear {
			//Need this workaround because the Image view does not animate with the Card View
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				withAnimation(.easeInOut(duration: 0.5)) {
					self.isShowingMemberImage = true
				}
			}
		}
		.onDisappear {
			self.isShowingMemberImage = false
		}
	}
}

struct ChatView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			ChatView(viewModel: .init(tribe: Tribe.noop2), dismissAction: {})
		}
	}
}
