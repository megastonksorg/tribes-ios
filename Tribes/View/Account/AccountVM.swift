//
//  AccountVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import Foundation

extension AccountView {
	@MainActor class ViewModel: ObservableObject {
		let user: User
		
		@Published var banner: BannerData?
		
		init(user: User) {
			self.user = user
		}
		
		func copyAddress() {
			PasteboardClient.shared.copyText(user.walletAddress)
			self.banner = BannerData(detail: AppConstants.addressCopied, type: .success)
		}
	}
}
