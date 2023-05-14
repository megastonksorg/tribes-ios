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
						gridElement(action: { viewModel.showTeaView(id: draft.id.uuidString) }, timeStamp: draft.timeStamp) {
							MessageDraftView(
								draft: draft,
								isMuted: true,
								isPlaying: true,
								retryDraft: { _ in },
								deleteDraft: { _ in }
							)
							.overlay(Color.black.opacity(0.8))
						}
						.id(draft.id)
					}
					ForEach(viewModel.tea) { tea in
						gridElement(action: { viewModel.showTeaView(id: tea.id) }, timeStamp: tea.timeStamp) {
							MessageView(
								currentTribeMember: viewModel.currentTribeMember,
								message: tea,
								tribe: viewModel.tribe,
								isMuted: true,
								isPlaying: true,
								isShowingCaption: false,
								isShowingIncomingAuthor: false
							)
							.if(!tea.isRead) { view in
								view
									.scaledToFit()
									.blur(radius: 16)
							}
						}
						.id(tea.id)
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
				Button(action: { viewModel.showTribeProfile() }) {
					VStack {
						ChatHeaderView(context: .teaPot, members: viewModel.tribe.members)
						TextView(viewModel.tribe.name, style: .tribeName(15, false))
							.padding(.bottom, 6)
					}
				}
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
		.sheet(isPresented: $viewModel.isShowingTribeProfile) {
			NavigationView {
				TribeProfileView(viewModel: TribeProfileView.ViewModel(tribe: viewModel.tribe))
					.navigationTitle("")
			}
			.tint(Color.app.secondary)
		}
		.overlay(isShown: viewModel.isShowingTeaView) {
			TeaView(
				viewModel: self.viewModel,
				closeButtonAction: { viewModel.dismissTeaView() }
			)
			.transition(.asymmetric(insertion: .opacity, removal: .identity))
		}
	}
	
	@ViewBuilder
	func gridElement<Element: View>(action: @escaping () -> (), timeStamp: Date?, element: @escaping () -> Element) -> some View {
		Button(action: { action() }) {
			ZStack {
				Rectangle()
					.fill(Color.black)
				element()
			}
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
