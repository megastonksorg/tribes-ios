//
//  DraftView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct DraftView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		if let content = viewModel.content {
			Group {
				GeometryReader { proxy in
					Group {
						ContentView(content: content)
					}
					.frame(size: proxy.size)
				}
				.ignoresSafeArea()
				.overlay(alignment: .topTrailing) {
					Color.gray.opacity(0.02)
						.frame(dimension: 70)
						.onTapGesture {
							viewModel.resetContent()
						}
						.overlay(
							XButton {
								viewModel.resetContent()
							}
						)
				}
			}
			.safeAreaInset(edge: .bottom) {
				if let directRecipient = viewModel.directRecipient {
					SymmetricHStack(
						content: {
							tribeAvatar(tribe: directRecipient)
						},
						leading: { EmptyView() },
						trailing: {
							sendTeaButton()
						}
					)
				} else {
					let spacing: CGFloat = 4
					HStack(spacing: 0) {
						ScrollView(.horizontal, showsIndicators: false) {
							LazyHStack(spacing: 14) {
								Spacer()
									.frame(width: spacing)
								ForEach(viewModel.recipients) {
									tribeAvatar(tribe: $0)
								}
							}
						}
						.frame(maxHeight: 140)
						Spacer(minLength: spacing)
						sendTeaButton()
					}
					.padding(.horizontal, 6)
				}
			}
		}
	}
	
	@ViewBuilder
	func tribeAvatar(tribe: Tribe) -> some View {
		let isSelected: Bool = viewModel.selectedRecipients[id: tribe.id] != nil
		TribeAvatar(
			context: .draftView,
			tribe: tribe,
			size: 90,
			isSelected: isSelected,
			avatarContextAction: { _ in },
			primaryAction: { viewModel.tribeTapped(tribe: $0) },
			secondaryAction: { viewModel.tribeTapped(tribe: $0) },
			inviteAction: { _ in },
			leaveAction: { _ in }
		)
		.dropShadow()
		.dropShadow()
		.dropShadow()
		.dropShadow()
	}
	
	@ViewBuilder
	func sendTeaButton() -> some View {
		Button(action: {  }) {
			Image(systemName: "cup.and.saucer.fill")
				.font(.system(size: SizeConstants.teaCupSize))
				.foregroundColor(Color.app.tertiary)
				.padding()
				.background(Circle().fill(Color.app.secondary))
		}
	}
}

struct DraftView_Previews: PreviewProvider {
	static var previews: some View {
		DraftView(
			viewModel: .init(
				content: .image(URL(string: "https://kingsleyokeke.blob.core.windows.net/videos/Untitled.mp4")!),
				directRecipient: nil
			)
		)
	}
}
