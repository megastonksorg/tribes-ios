//
//  ChatView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import IdentifiedCollections
import SwiftUI

struct ChatView: View {
	var screenHeight: CGFloat = UIScreen.main.bounds.maxY
	var screenWidth: CGFloat = UIScreen.main.bounds.maxX
	
	@FocusState private var focusedField: ViewModel.FocusField?
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			VStack(spacing: 0) {
				ScrollViewReader { readerProxy in
					ScrollView(showsIndicators: false) {
						LazyVStack(spacing: 0) {
							HStack(spacing: 2) {
								TextView("Only comms from the past 24 hours", style: .hint)
								Image(systemName: "clock.fill")
									.foregroundColor(Color.gray)
								TextView("are shown", style: .hint)
							}
							.padding(.bottom, 8)
							.padding(.top)
							ForEach(viewModel.messages) { message in
								MessageView(
									currentTribeMember: viewModel.currentTribeMember,
									message: message,
									tribe: viewModel.tribe,
									isMuted: true,
									isPlaying: false,
									isShowingCaption: true,
									isShowingIncomingAuthor: viewModel.shouldShowMessageAuthor(message: message),
									contextMessageAction: {
										self.focusedField = nil
										viewModel.showTea($0)
									}
								)
								.id(message.id)
								.onAppear { viewModel.markAsRead(message) }
							}
							ForEach(viewModel.failedDrafts) { draft in
								MessageDraftView(
									draft: draft,
									isMuted: true,
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
				
				ZStack {
					Color.clear
					if viewModel.isSendingMessage {
						SendingIndicator()
					}
				}
				.frame(height: 4)
				HStack {
					Button(action: { self.focusedField = nil }) {
						Image(systemName: "keyboard.chevron.compact.down")
							.font(Font.app.title2)
							.foregroundColor(Color.gray)
							.opacity(self.focusedField == nil ? 0.2 : 0.5)
					}
					.disabled(self.focusedField == nil)
					
					ZStack(alignment: .leading) {
						Group {
							Text("Message ")
								.foregroundColor(Color.gray)
							+
							Text(viewModel.tribe.name)
								.foregroundColor(Color.app.tertiary)
						}
						.lineLimit(2)
						.opacity(viewModel.isHintTextVisible ? 1.0 : 0.0)
						HStack(spacing: 2) {
							TextField("", text: $viewModel.text.max(SizeConstants.textMessageLimit), axis: .vertical)
								.tint(Color.white)
								.lineLimit(1...4)
								.foregroundColor(.white)
								.focused($focusedField, equals: .text)
							MessageBottomButton(
								style: .send,
								action: { viewModel.sendMessage() }
							)
							.opacity(viewModel.canSendText ? 1.0 : 0.0)
						}
					}
					.font(Font.app.body)
					.multilineTextAlignment(.leading)
					.padding(.horizontal, 12)
					.padding(.vertical, 10)
					.background {
						RoundedRectangle(cornerRadius: SizeConstants.textFieldCornerRadius)
							.stroke(Color.app.secondary, lineWidth: 1)
							.opacity(viewModel.canSendText ? 1.0 : 0.4)
							.transition(.opacity)
							.animation(.easeInOut, value: viewModel.canSendText)
					}
					.opacity(viewModel.canChat ? 1.0 : 0.5)
					.disabled(!viewModel.canChat)
				}
				.padding(.horizontal)
				.padding(.top, 4)
			}
			.padding(.bottom, 4)
		}
		.background(Color.app.background)
		.toolbar {
			ToolbarItem(placement: .principal) {
				Button(action: { viewModel.showTribeProfile() }) {
					ChatHeaderView(
						context: .chat,
						members: IdentifiedArrayOf(
							uniqueElements: viewModel.tribe.members
						)
					)
				}
				.offset(y: -4)
			}
		}
		.overlay(isShown: viewModel.currentShowingTea != nil) {
			if let currentShowingTea = viewModel.currentShowingTea {
				GeometryReader { proxy in
					ZStack {
						MessageView(
							currentTribeMember: viewModel.currentTribeMember,
							message: currentShowingTea,
							tribe: viewModel.tribe,
							isMuted: false,
							isPlaying: true,
							isShowingCaption: true,
							isShowingIncomingAuthor: false
						)
					}
					.frame(size: proxy.size)
				}
				.ignoresSafeArea()
				.overlay(alignment: .top) {
					Color.black.opacity(0.4)
						.blur(radius: 40)
						.frame(height: 140)
						.ignoresSafeArea()
				}
				.background(Color.app.secondary)
				.transition(.asymmetric(insertion: .opacity, removal: .identity))
				.overlay(alignment: .topLeading) {
					TeaViewTribeHeader(tribe: viewModel.tribe, timeStamp: currentShowingTea.timeStamp)
						.padding()
						.if(!currentShowingTea.isEncrypted) { view in
							/**
							 We need this because when there is no content,
							 the view alignment shifts outside of the parent view because we ignore safe area for the content
							 */
							view
								.padding(.horizontal)
						}
				}
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
				}
			}
		}
		.sheet(isPresented: $viewModel.isShowingTribeProfile) {
			NavigationView {
				TribeProfileView(viewModel: TribeProfileView.ViewModel(tribe: viewModel.tribe))
					.navigationTitle("")
			}
			.tint(Color.app.secondary)
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
							Color.app.darkRed
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
		NavigationView {
			VStack {
				ChatView(viewModel: .init(tribe: Tribe.noop2))
			}
			.navigationBarTitleDisplayMode(.large)
		}
	}
}
