//
//  AccountVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import Foundation
import IdentifiedCollections
import LocalAuthentication
import SwiftUI

extension AccountView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: String, Hashable, Identifiable {
			case editFullName
			
			var id: String { self.rawValue }
		}
		
		let user: User
		let phrase: IdentifiedArrayOf<MnemonicWord>
		
		@Published var editFullNameText: String = ""
		@Published var editImage: UIImage?
		
		@Published var banner: BannerData?
		@Published var isSecretKeyLocked: Bool = true
		@Published var isShowingImagePicker: Bool = false
		@Published var isShowingSettings: Bool = false
		
		var isUpdateButtonEnabled: Bool {
			editFullNameText.trimmingCharacters(in: .whitespaces) != user.fullName || editImage != nil
		}
		
		init(user: User) {
			self.user = user
			self.phrase = {
				guard let mnemonic = KeychainClient.shared.get(key: .mnemonic) else { return [] }
				let phrase: [MnemonicWord] = mnemonic.split(separator: " ").map{ MnemonicWord(text: String($0), isSelectable: false, isAlternateStyle: false) }
				return IdentifiedArray(uniqueElements: phrase)
			}()
			self.editFullNameText = user.fullName
			NotificationCenter
				.default.addObserver(
					self,
					selector: #selector(lockKey),
					name: .appInActive,
					object: nil
				)
		}
		
		func copyAddress() {
			PasteboardClient.shared.copyText(user.walletAddress)
			self.banner = BannerData(detail: AppConstants.addressCopied, type: .success)
		}
		
		func setIsShowingImagePicker(_ isShowing: Bool) {
			self.isShowingImagePicker = isShowing
		}
		
		func toggleSettings() {
			withAnimation(.linear.speed(4.0)) {
				self.isShowingSettings.toggle()
			}
			if !self.isShowingSettings {
				self.editImage = nil
			}
		}
		
		@objc func lockKey() {
			self.isSecretKeyLocked = true
		}
		
		func unlockKey() {
		#if targetEnvironment(simulator)
			self.isSecretKeyLocked = false
		#else
			let context = LAContext()
			var error: NSError?
			
			// check whether biometric authentication is possible
			if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
				let reason = "Your biometric unlocks your secret key"
				context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
					if success {
						DispatchQueue.main.async {
							self.isSecretKeyLocked = false
						}
					} else {
						DispatchQueue.main.async {
							self.banner = BannerData(detail: "Could not validate your biometric", type: .error)
						}
					}
				}
			} else {
				// no biometrics
				DispatchQueue.main.async {
					self.banner = BannerData(detail: "Configure your biometric in your device settings to access your secret key", type: .error)
				}
			}
		#endif
		}
	}
}
