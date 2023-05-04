//
//  TeaPotView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-03.
//

import SwiftUI

struct TeaPotView: View {
	let gridSpacing: CGFloat = 2
	let closeButtonAction: () -> ()
	@StateObject var viewModel: TeaView.ViewModel
	
	var body: some View {
		VStack {
			ScrollView(showsIndicators: false) {
				LazyVGrid(columns: Array(repeating: GridItem(.flexible(maximum: 160), spacing: gridSpacing), count: 3), spacing: gridSpacing) {
					ForEach(viewModel.drafts) { draft in
						gridElement(action: {}, timeStamp: draft.timeStamp) {
							MessageDraftView(
								draft: draft,
								isPlaying: true,
								retryDraft: { _ in },
								deleteDraft: { _ in }
							)
						}
						.id(draft.id)
					}
					ForEach(viewModel.tea) { tea in
						gridElement(action: {}, timeStamp: tea.timeStamp) {
							MessageView(
								currentTribeMember: viewModel.currentTribeMember,
								message: tea,
								tribe: viewModel.tribe,
								isMuted: true,
								isPlaying: true,
								isShowingCaption: false,
								isShowingIncomingAuthor: false
							)
						}
						.id(tea.body)
					}
				}
				MessageBottomButton(style: .close) {
					
				}
				.opacity(0)
			}
			.overlay(alignment: .bottomTrailing) {
				MessageBottomButton(style: .close) {
					closeButtonAction()
				}
				.padding(.trailing)
			}
		}
		.background(Color.app.background)
		.safeAreaInset(edge: .top) {
			VStack {
				ChatHeaderView(context: .teaPot, members: viewModel.tribe.members)
				TextView(viewModel.tribe.name, style: .tribeName(15, false))
					.padding(.bottom, 6)
			}
			.frame(maxWidth: .infinity)
			.background {
				ZStack {
					Rectangle()
						.fill(.ultraThinMaterial)
					Rectangle()
						.fill(Color.app.background.opacity(0.6))
				}
				.edgesIgnoringSafeArea(.top)
			}
		}
	}
	
	@ViewBuilder
	func gridElement<Element: View>(action: @escaping () -> (), timeStamp: Date?, element: @escaping () -> Element) -> some View {
		Button(action: { action() }) {
			element()
				.frame(height: 200)
				.clipShape(Rectangle())
				.overlay(alignment: .bottomLeading) {
					Text("\(timeStamp?.timeAgoDisplay() ?? "")")
						.font(Font.app.callout)
						.foregroundColor(Color.white)
						.padding([.leading, .bottom], 6)
						.fixedSize(horizontal: true, vertical: false)
				}
		}
		.buttonStyle(.bright)
	}
}

struct TeaPotView_Previews: PreviewProvider {
	static var previews: some View {
		TeaPotView(closeButtonAction: {}, viewModel: .init(tribe: Tribe.noop2))
	}
}
