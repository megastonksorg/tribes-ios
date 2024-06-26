//
//  NewSecretKeyVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import Combine
import SwiftUI
import IdentifiedCollections

extension NewSecretKeyView {
	@MainActor class ViewModel: ObservableObject {
		
		var walletAddress: String?
		
		@Published var phrase: IdentifiedArrayOf<MnemonicWord> = []
		
		@Published var banner: BannerData?
		
		//Clients
		let walletClient = WalletClient.shared
		
		init() {
			switch self.walletClient.getMnemonic() {
			case .success(let mnemonic):
				let mnemonicWords: [MnemonicWord] =
				mnemonic.split(separator: " ").map{ MnemonicWord(text: String($0), isSelectable: false, isAlternateStyle: false) }
	
					let walletResult = self.walletClient.importWallet(mnemonic: mnemonic)
					switch walletResult {
						case .success(let hdWallet):
							self.walletAddress = self.walletClient.getAddress(hdWallet)
							self.phrase = IdentifiedArray(uniqueElements: mnemonicWords)
						case .failure(let error):
							self.banner = BannerData(error: error)
					}
				case .failure(let error):
					self.banner = BannerData(error: error)
			}
		}
		
		func verifyMnemonicPhrase() {
			guard let walletAddress = self.walletAddress else { return }
			AppRouter.pushStack(stack: .welcome(.createProfile(shouldShowHint: false, walletAddress: walletAddress)))
		}
	}
}
