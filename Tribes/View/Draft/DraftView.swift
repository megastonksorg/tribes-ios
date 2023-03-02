//
//  DraftView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct DraftView: View {
	
	@FocusState private var focusedField: ViewModel.FocusField?
	
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
					.overlay(
						Color.clear
							.contentShape(Rectangle())
							.onTapGesture {
								if self.focusedField == .caption {
									self.focusedField = nil
								} else {
									self.focusedField = .caption
								}
							}
					)
					.overlay {
						let fontColor: Color = Color.white
						TextField("", text: $viewModel.caption.max(SizeConstants.captionLimit), axis: .vertical)
							.font(Font.app.title3)
							.foregroundColor(fontColor)
							.tint(fontColor)
							.multilineTextAlignment(.center)
							.submitLabel(.done)
							.focused($focusedField, equals: .caption)
							.padding(.vertical, 6)
							.frame(maxWidth: .infinity)
							.background(Color.app.primary.opacity(0.4))
							.opacity(viewModel.isShowingCaption || self.focusedField == .caption ? 1.0 : 0.0)
							.onChange(of: viewModel.caption) { newValue in
								guard let newValueLastChar = newValue.last else { return }
								if newValueLastChar == "\n" {
									viewModel.caption.removeLast()
									self.focusedField = nil
								}
							}
					}
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
								.opacity(viewModel.canSendTea ? 1.0 : 0.0)
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
						if viewModel.canSendTea {
							Spacer(minLength: spacing)
							sendTeaButton()
						}
					}
					.padding(.horizontal, 6)
				}
			}
			.onAppear { viewModel.resetRecipients() }
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
		.opacity(viewModel.canSendTea ? 1.0 : 0.5)
	}
	
	@ViewBuilder
	func sendTeaButton() -> some View {
		Button(action: {  }) {
			Image(systemName: "cup.and.saucer.fill")
				.font(.system(size: SizeConstants.teaCupSize))
				.foregroundColor(Color.app.tertiary)
				.padding()
				.background(Circle().fill(Color.app.secondary))
				.offset(y: -10)
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
