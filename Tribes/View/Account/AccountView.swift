//
//  AccountView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import SwiftUI

struct AccountView: View {
	
	@StateObject var viewModel: ViewModel
	
	@Environment(\.dismiss) var dismiss
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			VStack {
				let isSecretKeyLocked = viewModel.isSecretKeyLocked
				UserAvatar(url: viewModel.user.profilePhoto)
					.frame(dimension: SizeConstants.profileImageFrame)
				Text(viewModel.user.fullName)
					.multilineTextAlignment(.center)
				WalletView(address: viewModel.user.walletAddress, copyAction: { viewModel.copyAddress() })
					.padding(.top)
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
			}
			.font(Font.app.title2)
			.foregroundColor(.white)
			.padding(.horizontal)
		}
		.pushOutFrame(alignment: .top)
		.banner(data: self.$viewModel.banner)
		.background(Color.app.background)
		.safeAreaInset(edge: .top) {
			HStack {
				Button(action: {}) {
					Image(systemName: "gearshape.fill")
				}
				.font(Font.app.title)
				.foregroundColor(Color.white)
				Spacer()
				XButton {
					dismiss()
				}
			}
			.padding(.horizontal)
		}
	}
}

struct AccountView_Previews: PreviewProvider {
	static var previews: some View {
		AccountView(viewModel: .init(user: User.noop))
	}
}
