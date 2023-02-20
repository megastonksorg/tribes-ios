//
//  AccountView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import SwiftUI

struct AccountView: View {
	@FocusState private var focusedField: ViewModel.FocusField?
	@StateObject var viewModel: ViewModel
	@Environment(\.dismiss) var dismiss
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		let isShowingSettings: Bool = viewModel.isShowingSettings
		VStack {
			VStack {
				let isSecretKeyLocked = viewModel.isSecretKeyLocked
				Button(action: { viewModel.setSheet(.imagePicker) }) {
					Group {
						if isShowingSettings {
							if let image = viewModel.editImage {
								Image(uiImage: image)
									.resizable()
									.resizable()
									.aspectRatio(contentMode: .fill)
									.clipShape(Circle())
							} else {
								UserAvatar(url: viewModel.user.profilePhoto)
									.overlay(isShown: isShowingSettings) {
										Circle()
											.fill(Color.black)
											.opacity(isShowingSettings ? 0.6 : 0.0)
											.transition(.opacity)
											.overlay(
												Image(systemName: AppConstants.editIcon)
													.font(Font.app.title)
													.fontWeight(.bold)
											)
									}
							}
						} else {
							UserAvatar(url: viewModel.user.profilePhoto)
						}
					}
					.frame(dimension: SizeConstants.profileImageFrame)
				}
				.disabled(!isShowingSettings)
				ZStack {
					TextField(
						"",
						text: Binding(
							get: { viewModel.editFullNameText },
							set: { viewModel.setEditFullNameText($0) }
						)
					)
					.disableAutoCorrection(isNameField: true)
					.focused($focusedField, equals: .editFullName)
					.tint(Color.white)
					.lineLimit(1)
					.opacity(isShowingSettings ? 1.0 : 0.0)
					Text(viewModel.user.fullName)
						.opacity(isShowingSettings ? 0.0 : 1.0)
				}
				.foregroundColor(Color.white)
				.multilineTextAlignment(.center)
					.padding(.top)
				if isShowingSettings {
					Spacer()
					Button(action: { viewModel.setSheet(.logout) }) {
						Text("Logout")
					}
					.buttonStyle(.expanded)
					Button(action: { viewModel.setSheet(.deleteAccount) }) {
						Text("Delete Account")
					}
					.buttonStyle(.expanded(invertedStyle: true))
					.padding(.bottom)
				} else {
					VStack {
						WalletView(address: viewModel.user.walletAddress, copyAction: { viewModel.copyAddress() })
						VStack(spacing: 0) {
							HStack {
								Text("Secret Key")
								Spacer()
							}
							.padding(.top, 30)
							LazyVGrid(columns: Array(repeating: GridItem(), count: SizeConstants.phraseGridCount), alignment: .center, spacing: SizeConstants.phraseGridSpacing) {
								ForEach(viewModel.phrase){ word in
									MnemonicWordView(word: Binding.constant(viewModel.phrase[id: word.id]))
										.padding(.vertical, 6)
								}
							}
							.padding(.horizontal, -10)
							.blur(radius: isSecretKeyLocked ? 6 : 0)
							.animation(.easeInOut, value: viewModel.isSecretKeyLocked)
							.overlay(isShown: isSecretKeyLocked) {
								Button(action: { viewModel.unlockKey() }) {
									Image(systemName: "lock.circle.fill")
										.symbolRenderingMode(.palette)
										.foregroundStyle(Color.app.secondary, Color.white)
										.font(.system(size: 50))
								}
							}
							
							Button(action: { viewModel.lockKey() }) {
								Image(systemName: "lock.open.fill")
									.foregroundColor(Color.app.secondary)
									.font(.system(size: 26))
									.padding(10)
									.background(Circle().fill(Color.white))
							}
							.padding(.top)
							.opacity(viewModel.isSecretKeyLocked ? 0.0 : 1.0)
						}
					}
					.padding(.horizontal)
				}
			}
			.font(Font.app.title2)
			.foregroundColor(.white)
			.onChange(of: viewModel.isShowingSettings) { newIsShowingSettings in
				if newIsShowingSettings {
					self.focusedField = .editFullName
				}
			}
			.onChange(of: viewModel.isUploadingImage) { isUploadingImage in
				if !isUploadingImage {
					self.focusedField = nil
				}
			}
		}
		.pushOutFrame(alignment: .top)
		.overlay(isShown: viewModel.isUploadingImage) {
			AppProgressView()
		}
		.banner(data: self.$viewModel.banner)
		.background(Color.app.background)
		.safeAreaInset(edge: .top) {
			HStack {
				if isShowingSettings {
					Button(action: {
						self.focusedField = nil
						viewModel.toggleSettings()
					}) {
						Text("Cancel")
							.font(Font.app.title2)
					}
				} else {
					Button(action: { viewModel.toggleSettings() }) {
						Image(systemName: "gearshape.fill")
					}
					.font(Font.app.title)
				}
				Spacer()
				if isShowingSettings {
					AppToolBar(
						.trailing,
						trailingTitle: "Update",
						trailingClosure: { viewModel.updateUser() }
					)
					.disabled(!viewModel.isUpdateButtonEnabled)
					.opacity(viewModel.isUpdateButtonEnabled ? 1.0 : 0.5)
				} else {
					XButton {
						dismiss()
					}
				}
			}
			.frame(height: 30)
			.foregroundColor(Color.white)
			.padding(.horizontal)
		}
		.sheet(
			isPresented: Binding(
				get: { viewModel.sheet != nil },
				set: { _ in viewModel.setSheet(nil) }
			)
		) {
			switch viewModel.sheet {
			case .imagePicker:
				ImagePicker(image: $viewModel.editImage)
			case .logout, .deleteAccount:
				logoutAndDeleteView()
			case .none:
				EmptyView()
			}
		}
		.onDisappear { viewModel.didDisappear() }
	}
	
	@ViewBuilder
	func logoutAndDeleteView() -> some View {
		if let sheet = viewModel.sheet {
			if sheet == .logout || sheet == .deleteAccount {
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
						Text(sheet.body)
							.padding(.top, 60)
						Text(sheet.requestForConfirmation)
							.font(Font.app.title3)
							.padding(.top)
						SymmetricHStack(
							content: {
								ZStack {
									Text(sheet.confirmationTitle)
										.foregroundColor(Color.gray.opacity(viewModel.logoutOrDeleteConfirmation.isEmpty ? 0.4 : 0.0))
									TextField("", text: $viewModel.logoutOrDeleteConfirmation)
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
						Button(action: { }) {
							Text(sheet.title)
						}
						.buttonStyle(sheet == .logout ? .expanded : .expanded(invertedStyle: true))
						.disabled(!viewModel.isConfirmationButtonEnabled)
						.padding(.bottom)
					}
					.font(Font.app.subTitle)
					.multilineTextAlignment(.center)
					.foregroundColor(Color.white)
					.padding(.horizontal)
				}
				.pushOutFrame()
				.background(Color.app.background)
			}
		}
	}
}

struct AccountView_Previews: PreviewProvider {
	static var previews: some View {
		AccountView(viewModel: .init(user: User.noop))
	}
}
