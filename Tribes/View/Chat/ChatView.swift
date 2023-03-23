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
							HStack(spacing: 2) {
								TextView("Only comms from the past 24 hours", style: .hint)
								Image(systemName: "clock.fill")
									.foregroundColor(Color.gray)
								TextView("are shown", style: .hint)
							}
							.padding(.bottom, 8)
							ForEach(viewModel.messages) { message in
								MessageView(
									currentTribeMember: viewModel.currentTribeMember,
									message: message,
									tribe: viewModel.tribe,
									isPlaying: false,
									isShowingIncomingAuthor: viewModel.shouldShowMessageAuthor(message: message),
									contextMessageAction: { viewModel.showTea($0) }
								)
								.id(message.id)
							}
							ForEach(viewModel.failedDrafts) { draft in
								MessageDraftView(
									draft: draft,
									isPlaying: false,
									retryDraft: { viewModel.retryDraft(draft: $0) },
									deleteDraft: { viewModel.deleteDraft(draft: $0) }
								)
								.id(draft.id)
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
						.onChange(of: viewModel.messageChangedId) { _ in
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
								viewModel.scrollToLastMessage(proxy: readerProxy)
							}
						}
						.onChange(of: viewModel.draftChangedId) { _ in
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
					}
				}
				
				let textFieldBarButtonSize: CGFloat = 40
				ZStack {
					Color.clear
					if viewModel.isSendingMessage {
						SendingIndicator()
					}
				}
				.frame(height: 4)
				HStack {
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
					Spacer()
					MessageBottomButton(
						style: viewModel.canSendText ? .send : .close,
						action: {
							if viewModel.canSendText {
								viewModel.sendMessage()
							} else {
								dismissAction()
							}
						}
					)
					.frame(dimension: textFieldBarButtonSize)
				}
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
					uniqueElements: viewModel.tribe.members
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
		.overlay(isShown: viewModel.currentShowingTea != nil) {
			if let currentShowingTea = viewModel.currentShowingTea {
				MessageView(
					currentTribeMember: viewModel.currentTribeMember,
					message: currentShowingTea,
					tribe: viewModel.tribe,
					isPlaying: true,
					isShowingIncomingAuthor: false
				)
				.overlay(alignment: .topLeading) {
					TeaViewTribeHeader(tribe: viewModel.tribe, timeStamp: currentShowingTea.timeStamp)
						.padding(.horizontal)
						.padding()
				}
				.background(Color.app.secondary)
				.transition(.asymmetric(insertion: .opacity, removal: .identity))
				.overlay(alignment: .bottom) {
					HStack {
						Spacer()
						MessageBottomButton(style: .close) {
							viewModel.dismissTea()
						}
						.background {
							Color.clear
								.frame(dimension: 60)
								.contentShape(Rectangle())
								.onTapGesture {
									viewModel.dismissTea()
								}
						}
					}
					.padding(.horizontal)
					.padding(.horizontal)
				}
			}
		}
		.sheet(
			isPresented: Binding(
				get: { viewModel.sheet != nil },
				set: { _ in viewModel.setSheet(nil) }
			)
		) {
			switch viewModel.sheet {
			case .removeMember:
				removeMemberSheet()
			case .none:
				EmptyView()
			}
		}
	}
	
	@ViewBuilder
	func memberCard(_ member: TribeMember) -> some View {
		let isCurrentMember: Bool = viewModel.currentTribeMember.id == member.id
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
			Button(action: { viewModel.requestToRemoveTribeMember() }) {
				Text(isCurrentMember ? "You" : "Remove")
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
			.disabled(isCurrentMember)
			.opacity(isCurrentMember ? 0.5 : 1.0)
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
	
	@ViewBuilder
	func removeMemberSheet() -> some View {
		if let sheet = viewModel.sheet {
			VStack {
				VStack {
					SymmetricHStack(
						content: {
							Text(sheet.title)
								.textCase(.uppercase)
								.font(Font.app.title3)
								.fontWeight(.semibold)
						},
						leading: { EmptyView() },
						trailing: {
							XButton {
								viewModel.setSheet(nil)
							}
						}
					)
					.padding(.top)
					
					Group {
						Text("\(sheet.body)")
							.foregroundColor(Color.gray)
						+
						Text(" \(viewModel.memberToShow?.fullName ?? "")")
							.foregroundColor(Color.white)
						+
						Text(" from ")
							.foregroundColor(Color.gray)
						+
						Text(viewModel.tribe.name)
							.foregroundColor(Color.app.tertiary)
					}
					.padding(.top, 60)
					Spacer()
					SymmetricHStack(
						content: {
							ZStack {
								Text(sheet.confirmationTitle)
									.foregroundColor(Color.gray.opacity(viewModel.removeConfirmation.isEmpty ? 0.4 : 0.0))
								TextField("", text: $viewModel.removeConfirmation)
									.tint(Color.white)
									.introspectTextField { textField in
										//We need this because focusField does not work in a sheet here
										textField.becomeFirstResponder()
									}
							}
						},
						leading: {
							Image(systemName: "exclamationmark.circle.fill")
						},
						trailing: { EmptyView() }
					)
					.font(Font.app.title)
					.padding(.top)
					Spacer()
					Button(action: { viewModel.removeTribeMember() }) {
						Text(sheet.title)
					}
					.buttonStyle(.expanded(invertedStyle: true))
					.disabled(!viewModel.isRemoveConfirmationButtonEnabled)
					.padding(.bottom)
				}
				.font(Font.app.subTitle)
				.multilineTextAlignment(.center)
				.foregroundColor(Color.white)
				.padding(.horizontal)
			}
			.pushOutFrame()
			.background(Color.app.background)
			.banner(data: self.$viewModel.sheetBanner)
			.overlay(isShown: viewModel.isProcessingRemoveRequest) {
				AppProgressView()
			}
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
