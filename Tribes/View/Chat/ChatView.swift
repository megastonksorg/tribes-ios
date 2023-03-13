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
						LazyVStack(spacing: 0) {
							ForEach(viewModel.messages) { message in
								MessageView(
									currentTribeMember: viewModel.currentTribeMember,
									message: message,
									tribe: viewModel.tribe,
									isPlaying: false
								)
								.id(message.id)
							}
							ForEach(viewModel.drafts) { draft in
								if draft.status == .failedToUpload {
									MessageDraftView(
										draft: draft,
										isPlaying: false,
										retryDraft: { viewModel.retryDraft(draft: $0) },
										deleteDraft: { viewModel.deleteDraft(draft: $0) }
									)
									.id(draft.id)
								}
							}
							.transition(.asymmetric(insertion: .opacity, removal: .slide))
						}
						.padding(.horizontal, 10)
						.onChange(of: focusedField) { focusField in
							if focusField == .text {
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
									viewModel.scrollToLastMessage(proxy: readerProxy)
								}
							}
						}
						.onChange(of: viewModel.messages.count) { _ in
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
								viewModel.scrollToLastMessage(proxy: readerProxy)
							}
						}
						.onChange(of: viewModel.drafts.count) { _ in
							viewModel.scrollToLastMessage(proxy: readerProxy)
						}
						.onAppear { viewModel.scrollToLastMessage(proxy: readerProxy) }
					}
					.scrollDismissesKeyboard(.immediately)
				}
				
				if !viewModel.canChat {
					Group {
						Text("Invite members to ")
							.foregroundColor(Color.gray)
						+
						Text(viewModel.tribe.name)
							.foregroundColor(Color.app.tertiary)
						+
						Text(" to chat")
							.foregroundColor(Color.gray)
					}
				}
				
				let textFieldBarButtonSize: CGFloat = 40
				SendingIndicator()
					.frame(height: 4)
					.opacity(viewModel.isSendingMessage ? 1.0 : 0.0)
				SymmetricHStack(
					spacing: 4,
					content: {
						ZStack(alignment: .topLeading) {
							Group {
								Text("Message ")
									.foregroundColor(Color.gray)
								+
								Text(viewModel.tribe.name)
									.foregroundColor(Color.app.tertiary)
							}
							.lineLimit(2)
							.opacity(viewModel.canSendText ? 0.0 : 1.0)
							TextField("", text: $viewModel.text, axis: .vertical)
								.tint(Color.white)
								.lineLimit(1...4)
								.foregroundColor(.white)
								.focused($focusedField, equals: .text)
						}
						.font(Font.app.body)
						.multilineTextAlignment(.leading)
						.padding(.horizontal, 12)
						.padding(.vertical, 10)
						.background {
							RoundedRectangle(cornerRadius: 14)
								.stroke(Color.app.tertiary, lineWidth: 1)
								.opacity(viewModel.canSendText ? 1.0 : 0.0)
								.transition(.opacity)
								.animation(.easeInOut, value: viewModel.canSendText)
						}
						.opacity(viewModel.canChat ? 1.0 : 0.5)
						.disabled(!viewModel.canChat)
					},
					leading: {
						Button(action: {
							self.focusedField = nil
						}) {
							Image(systemName: "camera.fill")
								.font(Font.app.title2)
								.foregroundColor(Color.gray.opacity(0.8))
						}
						.frame(dimension: textFieldBarButtonSize)
						.opacity(viewModel.canChat ? 1.0 : 0.5)
						.disabled(!viewModel.canChat)
					},
					trailing: {
						Button(
							action: {
								if viewModel.canSendText {
									viewModel.sendMessage()
								} else {
									dismissAction()
								}
							}
						) {
							Image(systemName: viewModel.canSendText ? "paperplane.circle.fill" : "xmark.circle.fill")
								.font(.system(size: 30))
								.foregroundColor(Color.app.tertiary)
						}
						.frame(dimension: textFieldBarButtonSize)
					}
				)
				.padding(.horizontal)
				.padding(.top, 4)
			}
			.padding(.bottom, 4)
		}
		.background(Color.app.background)
		.safeAreaInset(edge: .top) {
			ChatHeaderView(
				action: {
					self.focusedField = nil
					viewModel.showTribeMemberCard($0)
				},
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
			if let tenure = member.joined.utcToCurrent().date?.timeAgoDisplay() {
				Text("Joined \(tenure)")
					.font(Font.app.footnote)
					.foregroundColor(Color.gray)
					.padding(.bottom)
			}
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

fileprivate struct SendingIndicator: View {
	@State var width: CGFloat = .zero
	@State var isAnimating: Bool = false
	
	var body: some View {
		ZStack(alignment: .leading) {
			Rectangle()
				.fill(Color.clear)
			Rectangle()
				.fill(
					LinearGradient(
						colors: [
							Color.app.secondary,
							Color.app.tertiary
						],
						startPoint: .leading,
						endPoint: .trailing
					)
				)
				.frame(width: width * 0.6)
				.offset(x: isAnimating ? width : 0)
				.animation(.linear.speed(0.2).repeatForever(autoreverses: false), value: self.isAnimating)
				.onAppear {
					self.isAnimating = true
				}
		}
		.readSize { size in
			self.width = size.width
		}
	}
}

struct ChatView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			ChatView(viewModel: .init(tribe: Tribe.noop1), dismissAction: {})
		}
	}
}
