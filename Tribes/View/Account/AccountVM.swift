//
//  AccountVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import Foundation
import IdentifiedCollections

extension AccountView {
	@MainActor class ViewModel: ObservableObject {
		let user: User
		let phrase: IdentifiedArrayOf<MnemonicWord>
		
		@Published var banner: BannerData?
		
		init(user: User) {
			self.user = user
			self.phrase = {
				guard let mnemonic = KeychainClient.shared.get(key: .mnemonic) else { return [] }
				let phrase: [MnemonicWord] = mnemonic.split(separator: " ").map{ MnemonicWord(text: String($0), isSelectable: false, isAlternateStyle: false) }
				return IdentifiedArray(uniqueElements: phrase)
			}()
		}
		
		func copyAddress() {
			PasteboardClient.shared.copyText(user.walletAddress)
			self.banner = BannerData(detail: AppConstants.addressCopied, type: .success)
		}
	}
}
