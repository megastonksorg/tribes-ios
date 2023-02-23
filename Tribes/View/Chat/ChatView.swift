//
//  ChatView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import IdentifiedCollections
import SwiftUI

struct ChatView: View {
	var dismissAction: () -> Void
	var screenHeight: CGFloat = UIScreen.main.bounds.maxY
	var screenWidth: CGFloat = UIScreen.main.bounds.maxX
	
	@FocusState private var focusedField: ViewModel.FocusField?
	
	@StateObject var viewModel: ViewModel
	
	@State var isShowingMemberImage: Bool = false
	
	init(viewModel: ViewModel, dismissAction: @escaping () -> Void) {
		self._viewModel = StateObject(wrappedValue: viewModel)
		self.dismissAction = dismissAction
	}
	var body: some View {
		VStack {
			VStack(spacing: 0) {
				ScrollViewReader { readerProxy in
					ScrollView {
						LazyVStack {
							ForEach(0..<100) {
								CalloutView(content: "Okay this is a random Text. Do what you will with this.\($0)")
								Text("\($0)")
									.foregroundColor(.white)
									.padding(.top)
									.pushOutFrame()
									.id($0)
							}
						}
						.onChange(of: focusedField) {
							if $0 == .text {
								withAnimation(.easeIn) {
									readerProxy.scrollTo(99, anchor: .top)
								}
							}
						}
					}
					.scrollDismissesKeyboard(.interactively)
				}
				HStack(alignment: .bottom) {
					Button(action: {
						self.focusedField = nil
					}) {
						Image(systemName: "camera.fill")
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
				.padding([.horizontal, .bottom])
			}
		}
		.background(Color.app.background)
		.safeAreaInset(edge: .top) {
			ChatHeaderView(
				action: { viewModel.showTribeMemberCard($0) },
				members: IdentifiedArrayOf(
					uniqueElements: viewModel.tribe.members.others
				)
			)
		}
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
	func memberCard(_ member: TribeMember) -> some View {
		VStack {
			SymmetricHStack(
				content: {
					Text(member.fullName)
						.font(Font.app.title3)
						.foregroundColor(Color.white)
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
				Text(viewModel.tribe.name)
					.foregroundColor(Color.app.tertiary)
				+
				Text(" member since \(member.joined)")
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
