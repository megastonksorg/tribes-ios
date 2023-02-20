//
//  AuthenticateView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-30.
//

import SwiftUI

struct AuthenticateView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		let user = viewModel.user
		VStack {
			HStack {
				Button(action: { viewModel.cancel() }) {
					Text("Cancel")
						.opacity(0)
				}
				Spacer()
				Text("Authentication")
					.fontWeight(.bold)
					.foregroundColor(.white)
				Spacer()
				Button(action: { self.viewModel.cancel() }) {
					Text("Cancel")
						.foregroundColor(.gray)
						.opacity(0.8)
				}
			}
			CachedImage(
				url: user.profilePhoto,
				content: { uiImage in
					Image(uiImage: uiImage)
						.resizable()
						.clipShape(Circle())
				},
				placeHolder: {
					ImagePlaceholderView()
				}
			)
			.frame(dimension: SizeConstants.profileImageFrame)
			.padding(.top, 40)
			.opacity(viewModel.context == .signUp ? 1.0 : 0.0)
			
			Text(viewModel.context == .signIn ? "Welcome Back 😀" : viewModel.user.fullName)
				.font(Font.app.title3)
				.fontWeight(.semibold)
				.foregroundColor(.white)
				.padding(.top)
			
			WalletView(address: viewModel.user.walletAddress, copyAction: { viewModel.copyAddress() })
				.padding(.top, 60)
			
			Spacer()
			
			Text("By clicking authenticate, you will sign a message with your wallet for verification")
				.font(Font.app.caption)
				.foregroundColor(.gray)
				.multilineTextAlignment(.center)
			
			Button(action: { viewModel.authenticate() }) {
				Text("Authenticate")
			}
			.buttonStyle(.expanded)
		}
		.padding(.horizontal)
		.alert(
			"Do you want to cancel the authentication process",
			isPresented: $viewModel.isShowingAlert,
			actions: {
				Button(role: .destructive, action: { viewModel.alertYesTapped() }) {
					Text("Yes")
				}
				Button(role: .cancel, action: {}) {
					Text("No")
				}
			},
			message: {
				Text(viewModel.alertDetail)
			}
		)
		.overlay(isShown: viewModel.isLoading) {
			AppProgressView()
		}
		.banner(data: self.$viewModel.banner)
		.background(Color.app.background)
	}
}

struct AuthenticateView_Previews: PreviewProvider {
	static var previews: some View {
		AuthenticateView(viewModel: .init(context: .signIn, user: User.noop))
	}
}
