//
//  TeaView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct TeaView: View {
	
	let closeButtonAction: () -> ()
	
	@FocusState private var focusedField: ViewModel.FocusField?
	
	@StateObject var viewModel: ViewModel
	
	@ObservedObject var keyboardClient: KeyboardClient = KeyboardClient.shared
	
	@State var currentPlaybackProgress: Float = 0
	@State var currentPillOffset: CGFloat = 0
	@State var pillWidth: CGFloat = 0
	
	init(viewModel: TeaView.ViewModel, closeButtonAction: @escaping () -> ()) {
		self.closeButtonAction = closeButtonAction
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			let yOffset: CGFloat = {
				if keyboardClient.height == 0 {
					return 0
				} else {
					return keyboardClient.height - 25
				}
			}()
			header()
				.overlay(alignment: .top) {
					Color.black.opacity(0.4)
						.blur(radius: 40)
						.frame(height: 140)
						.ignoresSafeArea(edges: .top)
				}
			Spacer()
			HStack {
				if !viewModel.tea.isEmpty && viewModel.currentTeaId != nil {
					ZStack(alignment: .topLeading) {
						Group {
							Text("Message ")
								.foregroundColor(Color.white)
							+
							Text(viewModel.tribe.name)
								.foregroundColor(Color.app.tertiary)
						}
						.lineLimit(1)
						.opacity(viewModel.isHintTextVisible ? 1.0 : 0.0)
						TextField("", text: $viewModel.text.max(SizeConstants.textMessageLimit), axis: .vertical)
							.tint(Color.white)
							.lineLimit(1...4)
							.foregroundColor(.white)
							.submitLabel(.done)
							.focused($focusedField, equals: .text)
							.onChange(of: viewModel.text) { newValue in
								guard let indexOfNewLine = newValue.firstIndex(of: "\n") else { return }
								viewModel.text.remove(at: indexOfNewLine)
								self.focusedField = nil
								viewModel.sendMessage()
							}
					}
					.font(Font.app.body)
					.multilineTextAlignment(.leading)
					.padding(.horizontal, 12)
					.padding(.vertical, 14)
					.background {
						ZStack {
							let cornerRadius: CGFloat = SizeConstants.textFieldCornerRadius
							RoundedRectangle(cornerRadius: cornerRadius)
								.fill(LinearGradient.dropShadow.opacity(0.5))
							RoundedRectangle(cornerRadius: cornerRadius)
								.stroke(Color.white, lineWidth: 1)
						}
					}
					.dropShadow()
					.dropShadow()
				}
				
				Menu(content: {
					Button(action: { viewModel.deleteMessage() }) {
						Label("Delete", systemImage: "trash.circle.fill")
							.font(Font.app.title)
					}
				}, label: {
					Image(systemName: "ellipsis")
						.font(Font.app.title)
						.padding(4)
						.padding(.vertical, 10)
						.rotationEffect(.degrees(-90))
				})
				.foregroundColor(Color.white)
				.dropShadow()
				.dropShadow()
				.opacity(viewModel.isAuthorOfCurrentTea ? 1.0 : 0.0)
				.frame(height: 30)
				
				Spacer()
				MessageBottomButton(style: .close) {
					closeButtonAction()
				}
				.background {
					Color.clear
						.frame(dimension: 60)
						.contentShape(Rectangle())
						.onTapGesture {
							closeButtonAction()
						}
				}
			}
			.offset(y: -yOffset)
		}
		.padding(.horizontal)
		.background {
			HStack(spacing: 10) {
				Color.clear.pushOutFrame()
					.allowsHitTesting(true)
					.contentShape(Rectangle())
					.onTapGesture {
						viewModel.previousDraftOrTea()
					}
				
				Color.clear.pushOutFrame()
					.allowsHitTesting(true)
					.contentShape(Rectangle())
					.onTapGesture {
						viewModel.nextDraftOrTea()
					}
			}
			.overlay {
				if let currentDraftId = viewModel.currentDraftId,
				   let currentDraft = viewModel.drafts[id: currentDraftId] {
					draftRetryButton(currentDraft: currentDraft)
				}
			}
			.overlay(isShown: keyboardClient.height != 0) {
				Color.black.opacity(0.4)
					.ignoresSafeArea()
			}
		}
		.background {
			ZStack {
				ForEach(viewModel.drafts) { draft in
					let isPlaying: Bool = draft.id == viewModel.currentDraftId
					MessageDraftView(
						draft: draft,
						isMuted: !isPlaying,
						isPlaying: isPlaying,
						retryDraft: { _ in },
						deleteDraft: { _ in }
					)
					.onPreferenceChange(PlaybackProgressKey.self) {
						self.currentPlaybackProgress = $0
					}
					.opacity(draft.id == viewModel.currentDraftId ? 1.0 : 0.0)
				}
				ForEach(viewModel.tea) { tea in
					MessageView(
						currentTribeMember: viewModel.currentTribeMember,
						message: tea,
						tribe: viewModel.tribe,
						isMuted: false,
						isPlaying: tea.id == viewModel.currentTeaId,
						isShowingCaption: true,
						isShowingIncomingAuthor: false
					)
					.onPreferenceChange(PlaybackProgressKey.self) {
						self.currentPlaybackProgress = $0
					}
					.id(tea.body)
					.opacity(tea.id == viewModel.currentTeaId ? 1.0 : 0.0)
				}
				if viewModel.isEmpty {
					emptyTeaView()
				}
			}
			.background(Color.app.primary)
			.ignoresSafeArea(.keyboard)
			.onChange(of: viewModel.currentPill) { _ in
				self.currentPlaybackProgress = 0
			}
		}
		.ignoresSafeArea(.keyboard)
		.onAppear { viewModel.didAppear() }
	}
	
	@ViewBuilder
	func header() -> some View {
		VStack {
			pillsView()
			HStack(spacing: 6) {
				let viewersCount = viewModel.currentTeaViewersIds.count
				let isShowingViewersButton: Bool = {
					return viewModel.currentTea != nil &&
					!(viewModel.currentTea?.isEncrypted ?? false) &&
					viewersCount > 0
				}()
				TeaViewTribeHeader(tribe: viewModel.tribe, timeStamp: viewModel.currentTea?.timeStamp)
				Spacer(minLength: 0)
				HStack(spacing: 0) {
					Image(systemName: "eye.circle.fill")
						.font(.system(size: 20))
						.foregroundColor(Color.app.tertiary.opacity(0.6))
					Text("\(viewersCount)")
						.font(Font.app.body)
						.foregroundColor(Color.app.tertiary)
				}
				.opacity(isShowingViewersButton ? 1.0 : 0.0)
			}
			.padding(.top)
		}
	}
	
	@ViewBuilder
	func emptyTeaView() -> some View {
		VStack(spacing: 40) {
			TextView("Looks like everyone is still asleep", style: .pageTitle)
				.multilineTextAlignment(.center)
			HStack {
				TextView("Be the first to share", style: .pageTitle)
				Image(systemName: "photo.on.rectangle.angled")
					.font(Font.app.title)
					.foregroundColor(Color.white)
			}
		}
	}
	
	@ViewBuilder
	func pillsView() -> some View {
		let count = viewModel.draftAndTeaIds.count
		ZStack {
			pill(index: 0)
				.opacity(0)
			if count > 10 {
				LazyVGrid(columns: Array(repeating: GridItem(), count: 10)) {
					ForEach(0..<count, id: \.self) { pillIndex in
						pill(index: pillIndex)
							.readSize { self.pillWidth = $0.width }
					}
				}
			} else {
				HStack(spacing: 2) {
					ForEach(0..<count, id: \.self) { pillIndex in
						pill(index: pillIndex)
							.readSize { self.pillWidth = $0.width }
					}
				}
			}
		}
	}
	
	@ViewBuilder
	func pill(index: Int) -> some View {
		ZStack {
			let currentPillOffset: CGFloat = {
				if currentPlaybackProgress == 0 {
					if let currentTea = viewModel.currentTea {
						if currentTea.isEncrypted {
							return 0
						}
					}
					return viewModel.currentContentType == .video ? self.pillWidth : 0
				} else {
					return self.pillWidth * CGFloat(1.0 - self.currentPlaybackProgress)
				}
			}()
			Capsule()
				.fill(viewModel.isDraftOrTeaRead(pillIndex: index) ? Color.app.secondary.opacity(0.2) : Color.white)
				.id(index)
			Capsule()
				.fill(Color.app.secondary)
				.transition(.opacity)
				.opacity(viewModel.currentPill == index ? 1.0 : 0.0)
				.animation(.linear, value: self.currentPlaybackProgress)
				.offset(x: -currentPillOffset)
				.clipShape(Capsule())
				.id(self.currentPlaybackProgress)
		}
		.frame(height: 4)
	}
	
	@ViewBuilder
	func draftRetryButton(currentDraft: MessageDraft) -> some View {
		let isShowing: Bool = {
			return currentDraft.status == .failedToUpload || currentDraft.isStuckUploading
		}()
		VStack {
			Spacer()
			Text("Something went wrong")
				.font(Font.app.subHeader)
				.foregroundColor(Color.gray)
				.dropShadow()
			Button(action: { viewModel.retryFailedDraft() }) {
				HStack {
					Text("Retry")
					Image(systemName: "arrow.counterclockwise.circle.fill")
				}
				.font(Font.app.title)
				.foregroundColor(Color.white)
				.padding()
				.dropShadow()
				.dropShadow()
			}
			Spacer()
			Button(action: { viewModel.deleteDraft() }) {
				HStack {
					Image(systemName: "trash.circle.fill")
				}
				.font(.system(size: 40))
				.foregroundColor(Color.white)
				.padding()
				.dropShadow()
				.dropShadow()
			}
		}
		.opacity(isShowing ? 1.0 : 0.0)
	}
}

struct TeaView_Previews: PreviewProvider {
	static var previews: some View {
		TeaView(viewModel: .init(tribe: Tribe.noop2), closeButtonAction: {})
			.preferredColorScheme(.dark)
	}
}
