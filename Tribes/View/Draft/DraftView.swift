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
	
	@ObservedObject var keyboardClient: KeyboardClient = KeyboardClient.shared
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		if let content = viewModel.content {
			GeometryReader { proxy in
				ContentView(content: content, isPlaying: viewModel.isPlaying)
					.frame(size: proxy.size)
			}
			.ignoresSafeArea()
			.overlay(
				Color.clear
					.contentShape(Rectangle())
					.frame(height: 400)
					.onTapGesture {
						if self.focusedField == .caption {
							self.focusedField = nil
						} else {
							self.focusedField = .caption
						}
					}
			)
			.overlay(alignment: .topTrailing) {
				Color.gray.opacity(0.01)
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
			.overlay(alignment: .bottom) {
				let yOffset: CGFloat = {
					if keyboardClient.height == 0 {
						return SizeConstants.teaCaptionOffset
					} else {
						return keyboardClient.height - 35
					}
				}()
				TextField("", text: $viewModel.caption.max(SizeConstants.captionLimit), axis: .vertical)
					.styleForCaption()
					.submitLabel(.done)
					.focused($focusedField, equals: .caption)
					.opacity(viewModel.isShowingCaption || self.focusedField == .caption ? 1.0 : 0.0)
					.offset(y: -yOffset)
					.onChange(of: viewModel.caption) { newValue in
						guard let indexOfNewLine = newValue.firstIndex(of: "\n") else { return }
						viewModel.caption.remove(at: indexOfNewLine)
						self.focusedField = nil
					}
					.animation(.easeInOut.speed(1.0), value: yOffset)
			}
			.overlay(alignment: .bottom) {
				Group {
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
					}
				}
			}
			.overlay(isShown: viewModel.isUploading) {
				AppProgressView()
			}
			.onAppear { viewModel.resetRecipients() }
			.onDisappear { viewModel.didDisappear() }
		}
	}
	
	@ViewBuilder
	func tribeAvatar(tribe: Tribe) -> some View {
		let isSelected: Bool = viewModel.selectedRecipients[id: tribe.id] != nil
		TribeAvatar(
			context: .draftView(isSelected),
			tribe: tribe,
			size: 90,
			avatarContextAction: { _ in },
			primaryAction: { viewModel.tribeTapped(tribe: $0) },
			secondaryAction: { viewModel.tribeTapped(tribe: $0) },
			inviteAction: { _ in },
			leaveAction: { _ in }
		)
		.dropShadow()
		.opacity(viewModel.canSendTea ? 1.0 : 0.5)
	}
	
	@ViewBuilder
	func sendTeaButton() -> some View {
		Button(action: { viewModel.sendTea() }) {
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
				content: .image(URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!)
			)
		)
	}
}
