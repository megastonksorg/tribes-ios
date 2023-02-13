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
				UserAvatar(url: viewModel.user.profilePhoto)
					.frame(dimension: SizeConstants.profileImageFrame)
				Text(viewModel.user.fullName)
					.font(Font.app.title2)
					.foregroundColor(.white)
				WalletView(address: viewModel.user.walletAddress, copyAction: { viewModel.copyAddress() })
					.padding(.top)
			}
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
