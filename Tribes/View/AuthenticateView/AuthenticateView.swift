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
			AsyncImage(url: user.profilePhoto) { image in
				image
					.resizable()
					.clipShape(Circle())
			}
			placeholder:  {
				ImagePlaceholderView()
			}
			.frame(dimension: SizeConstants.profileImageFrame)
			.padding(.top, 40)
			
			Text(viewModel.user.fullName)
				.font(Font.app.title3)
				.fontWeight(.semibold)
				.foregroundColor(.white)
				.padding(.top)
			
			VStack(spacing: 4) {
				ExpandedHStack {
					Text("ETHEREUM")
						.font(Font.app.footnote)
						.foregroundColor(.gray)
				}

				ExpandedHStack {
					Text(String(stringLiteral: "$_,_ _ _._ _ USD"))
						.font(Font.app.title3)
						.fontWeight(.semibold)
						.foregroundColor(.white)
						.overlay {
							Text(String(stringLiteral: "* * * * * * *"))
								.offset(x: -18)
						}
				}
				
				ExpandedHStack {
					Text("WALLET ADDRESS")
						.font(Font.app.footnote)
						.foregroundColor(.gray)
				}
				.padding(.top, 30)
				
				HStack {
					Text(viewModel.user.walletAddress)
						.font(Font.app.title3)
						.fontWeight(.semibold)
						.foregroundColor(.white)
					
					Spacer()
					
					Button(action: { self.viewModel.copyAddress() }) {
						Image(systemName: "doc.on.doc.fill")
					}
				}
			}
			.foregroundColor(.white)
			.multilineTextAlignment(.leading)
			.lineLimit(1)
			.padding()
			.background(TextFieldBackgroundView())
			.padding(.top, 60)
			
			Spacer()
			
			Text("By clicking authenticate, you will sign a message with your wallet for verification")
				.font(Font.app.caption)
				.foregroundColor(.gray)
				.multilineTextAlignment(.center)
			
			Button(action: {}) {
				Text("Authenticate")
			}
			.buttonStyle(ExpandedButtonStyle())
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
				Text("Cancelling authentication will bring you back to the welcome screen. Your account creation will be saved")
			}
		)
		.banner(data: self.$viewModel.banner)
		.background(Color.app.background)
	}
}

fileprivate struct ExpandedHStack<Content: View>: View {
	@ViewBuilder var content: Content
	
	init(@ViewBuilder content: @escaping () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		HStack {
			content
			Spacer()
		}
	}
}

struct AuthenticateView_Previews: PreviewProvider {
	static var previews: some View {
		AuthenticateView(viewModel: .init(user: User.noop))
	}
}
