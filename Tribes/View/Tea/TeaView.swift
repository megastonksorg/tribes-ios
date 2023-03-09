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
	
	init(viewModel: TeaView.ViewModel, closeButtonAction: @escaping () -> ()) {
		self.closeButtonAction = closeButtonAction
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		GeometryReader { proxy in
			ZStack {
				ForEach(viewModel.drafts) { draft in
					MessageDraftView(draft: draft, isPlaying: draft.id == viewModel.currentDraftId)
						.opacity(draft.id == viewModel.currentDraftId ? 1.0 : 0.0)
				}
				ForEach(viewModel.tea) { tea in
					MessageView(
						currentTribeMember: viewModel.currentTribeMember,
						message: tea,
						tribe: viewModel.tribe,
						isPlaying: tea.id == viewModel.currentTeaId
					)
					.opacity(tea.id == viewModel.currentTeaId ? 1.0 : 0.0)
				}
				if viewModel.isEmpty {
					emptyTeaView()
				}
			}
			.frame(size: proxy.size)
		}
		.ignoresSafeArea()
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
				if !viewModel.tea.isEmpty {
					ZStack(alignment: .topLeading) {
						Group {
							Text("Message ")
								.foregroundColor(Color.white)
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
					.padding(.vertical, 14)
					.background {
						RoundedRectangle(cornerRadius: 14)
							.stroke(Color.white, lineWidth: 1)
							.transition(.opacity)
					}
					.dropShadow()
					.dropShadow()
					.offset(y: -yOffset)
				}
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
						VStack {
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
						}
						.opacity(currentDraft.status == .failedToUpload ? 1.0 : 0.0)
					}
				}
			}
		}
	}
	
	@ViewBuilder
	func header() -> some View {
		HStack(spacing: 10) {
			HStack(spacing: -12) {
				ForEach(0..<viewModel.tribe.members.count, id: \.self) { index in
					UserAvatar(url: viewModel.tribe.members[index].profilePhoto)
						.frame(dimension: 24)
						.zIndex(-Double(index))
				}
			}
			HStack(spacing: 0) {
				TextView("\(viewModel.tribe.name)", style: .tribeName(16))
					.multilineTextAlignment(.leading)
					.lineLimit(2)
				Text(" • 2hrs ago")
					.font(Font.app.body)
					.foregroundColor(Color.app.tertiary)
					.opacity(viewModel.isEmpty ? 0.0 : 1.0)
			}
			Spacer()
			XButton {
				closeButtonAction()
			}
			.padding([.top, .leading, .bottom])
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
}

struct TeaView_Previews: PreviewProvider {
	static var previews: some View {
		TeaView(viewModel: .init(tribe: Tribe.noop2), closeButtonAction: {})
			.preferredColorScheme(.dark)
	}
}
