//
//  ChatView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import SwiftUI

struct ChatView: View {
	@StateObject var viewModel: ViewModel
	
	@State var isShowingMemberImage: Bool = false
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	var body: some View {
		VStack {
			VStack {
				HStack {
					Spacer()
				}
				Text("Message")
					.foregroundColor(.white)
				Spacer()
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
			
			Spacer()
				.frame(height: 14)
			
			VStack{
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
						avatarContextAction: { _ in },
						primaryAction: { _ in },
						secondaryAction: { _ in },
						inviteAction: { _ in },
						leaveAction: { _ in }
					)
				}
			}
			.padding([.horizontal, .bottom])
			.padding(.bottom, 2)
			.offset(x: 2)
		}
		.pushOutFrame()
		.background(Color.app.background)
		.ignoresSafeArea()
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
					.frame(dimension: 50)
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
			ChatView(viewModel: .init(tribe: Tribe.noop2))
		}
	}
}
