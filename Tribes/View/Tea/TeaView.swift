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
		GeometryReader { proxy in
			ZStack {
				ForEach(viewModel.drafts) { draft in
					MessageDraftView(
						draft: draft,
						isPlaying: draft.id == viewModel.currentDraftId,
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
						isPlaying: tea.id == viewModel.currentTeaId,
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
		.overlay {
			VStack {
				let yOffset: CGFloat = {
					if keyboardClient.height == 0 {
						return 0
					} else {
						return keyboardClient.height - 25
					}
				}()
				header()
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
							.lineLimit(2)
							.opacity(viewModel.isHintTextHintVisible ? 1.0 : 0.0)
							TextField("", text: $viewModel.text, axis: .vertical)
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
							RoundedRectangle(cornerRadius: 14)
								.stroke(Color.white, lineWidth: 1)
								.transition(.opacity)
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
						.contentShape(Rectangle())
						.onTapGesture {
							viewModel.previousDraftOrTea()
						}
					
					Color.clear.pushOutFrame()
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
			}
		}
	}
	
	@ViewBuilder
	func header() -> some View {
		VStack {
			pillsView()
			HStack(spacing: 6) {
				ZStack(alignment: .leading) {
					let animation: Animation = Animation.easeIn.speed(2.0)
					HStack {
						HStack(spacing: -12) {
							ForEach(0..<viewModel.tribe.members.count, id: \.self) { index in
								UserAvatar(url: viewModel.tribe.members[index].profilePhoto)
									.frame(dimension: 24)
									.zIndex(-Double(index))
							}
						}
						HStack(spacing: 0) {
							Text("\(viewModel.tribe.name)")
								.font(Font.app.title3)
								.foregroundColor(Color.app.tertiary)
								.lineLimit(1)
							Text(" • \(viewModel.currentTea?.timeStamp.timeAgoDisplay() ?? "")")
								.font(Font.app.body)
								.foregroundColor(Color.app.tertiary)
								.opacity(viewModel.currentTea == nil ? 0.0 : 1.0)
						}
					}
					.opacity(viewModel.isShowingCurrentViewers ? 0.0 : 1.0)
					.transition(.opacity)
					.animation(animation, value: viewModel.isShowingCurrentViewers)
					
					HStack(spacing: 10) {
						ScrollView(.horizontal, showsIndicators: false) {
							LazyHStack {
								ForEach(viewModel.currentTeaViewersIds, id: \.self) { viewerId in
									if let tribeMember = viewModel.tribe.members[id: viewerId] {
										UserAvatar(url: tribeMember.profilePhoto)
											.frame(dimension: 40)
									}
								}
							}
						}
					}
					.frame(height: 40)
					.opacity(viewModel.isShowingCurrentViewers ? 1.0 : 0.0)
					.transition(.opacity)
					.animation(animation, value: viewModel.isShowingCurrentViewers)
				}
				Spacer(minLength: 0)
				Button(action: { viewModel.toggleViewers() }) {
					Image(systemName: viewModel.isShowingCurrentViewers ? "eye.slash.circle.fill" : "eye.circle.fill")
						.font(.system(size: 30))
						.foregroundColor(Color.app.tertiary.opacity(0.6))
						.padding(.vertical, 4)
						.transition(.identity)
						.animation(.easeInOut, value: viewModel.isShowingCurrentViewers)
						.opacity(viewModel.currentTea == nil ? 0.0 : 1.0)
				}
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
				TextView("Wake them up with some", style: .pageTitle)
				Image(systemName: "cup.and.saucer.fill")
					.font(Font.app.title)
					.foregroundColor(Color.app.tertiary)
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
					return viewModel.currentContentType == .video ? self.pillWidth : 0
				} else {
					return self.pillWidth * CGFloat(1.0 - self.currentPlaybackProgress)
				}
			}()
			Capsule()
				.fill(viewModel.isDraftOrTeaRead(pillIndex: index) ? Color.app.tertiary.opacity(0.2) : Color.white)
				.id(index)
			Capsule()
				.fill(Color.app.tertiary)
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
