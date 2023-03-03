//
//  WelcomePageVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import Foundation
import Combine

extension WelcomePageView {
	@MainActor class ViewModel: ObservableObject {
		
		private var hasGeneratedWallet: Bool = false
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var isLoading: Bool = false
		
		@Published var banner: BannerData?
		
		//Clients
		let walletClient = WalletClient.shared
		
		func generateNewWallet() {
			self.isLoading = true
			if !self.hasGeneratedWallet {
				switch self.walletClient.generateNewWallet() {
				case .success(let wallet):
					self.hasGeneratedWallet = true
						self.walletClient.saveMnemonic(mnemonic: wallet.mnemonic)
						AppRouter.pushStack(stack: .welcome(.createWallet))
				case .failure(let error):
					self.banner = BannerData(error: error)
				}
			}
			else {
				AppRouter.pushStack(stack: .welcome(.createWallet))
			}
			self.isLoading = false
		}
		
		func importWallet() {
			AppRouter.pushStack(stack: .welcome(.importWallet))
		}
	}
}
