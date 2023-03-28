//
//  AccountVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import Combine
import Foundation
import IdentifiedCollections
import LocalAuthentication
import SwiftUI

extension AccountView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
			case editFullName
		}
		
		enum Sheet: Equatable {
			case imagePicker
			case logout
			case deleteAccount
			
			var title: String {
				switch self {
				case .imagePicker: return ""
				case .logout: return "Logout"
				case .deleteAccount: return "Delete Account"
				}
			}
			
			var body: String {
				switch self {
				case .imagePicker: return ""
				case .logout: return "Please ensure you have stored your account secret somewhere safe because it will be wiped from your device\n\nYou will also lose access to your Tribes conversation history"
				case .deleteAccount: return "Your account will be wiped from this device\n\nYou will be removed from your Tribes and all your messages will be deleted.\n\nPlease store your secret key somewhere safe to access your funds"
				}
			}
			
			var confirmationTitle: String {
				switch self {
				case .imagePicker: return ""
				case .logout: return "Logout"
				case .deleteAccount: return "Delete"
				}
			}
			
			var requestForConfirmation: String {
				switch self {
				case .imagePicker: return ""
				case .logout: return "Type Logout below:"
				case .deleteAccount: return "Type Delete below:"
				}
			}
		}
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		let phrase: IdentifiedArrayOf<MnemonicWord>
		
		@Published var editFullNameText: String = ""
		@Published var editImage: UIImage?
		@Published var user: User
		@Published var logoutOrDeleteConfirmation: String = ""
		
		@Published var banner: BannerData?
		@Published var isSecretKeyLocked: Bool = true
		@Published var isShowingSettings: Bool = false
		@Published var isUpdatingImage: Bool = false
		@Published var isUpdatingName: Bool = false
		@Published var isDeletingAccount: Bool = false
		@Published var isProcessingLogoutRequest: Bool = false
		@Published var sheet: Sheet?
		
		var isUpdateButtonEnabled: Bool {
			if !isUpdatingImage && !isUpdatingName {
				let trimmedName = editFullNameText.trimmingCharacters(in: .whitespacesAndNewlines)
				if trimmedName.isValidName {
					return trimmedName != user.fullName.trimmingCharacters(in: .whitespacesAndNewlines) || editImage != nil
				}
				return false
			}
			return false
		}
		
		var isConfirmationButtonEnabled: Bool {
			return logoutOrDeleteConfirmation == sheet?.confirmationTitle
		}
		
		//Clients
		let apiClient: APIClient = APIClient.shared
		
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
		
		func didDisappear() {
			self.isShowingSettings = false
		}
		
		func copyAddress() {
			PasteboardClient.shared.copyText(user.walletAddress)
			self.banner = BannerData(detail: AppConstants.addressCopied, type: .success)
		}
		
		func executeSheetAction() {
			switch sheet {
			case .logout:
				self.sheet = nil
				self.isProcessingLogoutRequest = true
				AppState.updateAppState(with: .userRequestedLogout)
			case .deleteAccount:
				self.isDeletingAccount = true
				self.apiClient
					.deleteAccount()
					.sink(receiveCompletion: { [weak self] completion in
						guard let self = self else { return }
						switch completion {
						case .finished: return
						case .failure(let error):
							self.isDeletingAccount = false
							self.banner = BannerData(error: error)
						}
					}, receiveValue: { [weak self] _ in
						guard let self = self else { return }
						self.isDeletingAccount = false
						AppState.updateAppState(with: .userDeleted)
					})
					.store(in: &cancellables)
			case .imagePicker, .none:
				return
			}
		}
		
		func setEditFullNameText(_ text: String) {
			if text.trimmingCharacters(in: .whitespacesAndNewlines).count < SizeConstants.fullNameHigherLimit {
				self.editFullNameText = text
			}
		}
		
		func setSheet(_ sheet: Sheet?) {
			self.logoutOrDeleteConfirmation = ""
			self.sheet = sheet
		}
		
		func toggleSettings() {
			withAnimation(.linear.speed(4.0)) {
				self.isShowingSettings.toggle()
			}
			if !self.isShowingSettings {
				self.editImage = nil
			}
		}
		
		func updateUser() {
			self.isUpdatingImage = true
			self.isUpdatingName = true
			if editImage != nil {
				guard let resizedImage = self.editImage?.resizedTo(megaBytes: SizeConstants.imageMaxSizeInMb),
					  let croppedImageData = resizedImage.croppedAndScaled(toFill: SizeConstants.profileImageSize).pngData() else {
					self.banner = BannerData(detail: "Could not scale image. Please select a different image", type: .error)
					self.isUpdatingImage = false
					return
				}
				self.apiClient.uploadImage(imageData: croppedImageData)
					.flatMap { url -> AnyPublisher<URL, APIClientError>  in
						return self.apiClient.updateProfilePhoto(photoUrl: url)
					}
					.receive(on: DispatchQueue.main)
					.sink(receiveCompletion: { [weak self] completion in
						guard let self = self else { return }
						switch completion {
							case .finished: return
							case .failure(let error):
								self.banner = BannerData(error: error)
						}
					}, receiveValue: { [weak self] photoUrlResponse in
						guard let self = self else { return }
						self.isUpdatingImage = false
						self.editImage = nil
						self.user.profilePhoto = photoUrlResponse
						AppState.updateAppState(with: .userUpdated(self.user))
						self.isShowingSettings.toggle()
					})
					.store(in: &cancellables)
			} else {
				self.isUpdatingImage = false
			}
			if editFullNameText.trimmingCharacters(in: .whitespacesAndNewlines) != user.fullName.trimmingCharacters(in: .whitespacesAndNewlines) {
				apiClient.updateName(fullName: editFullNameText)
					.receive(on: DispatchQueue.main)
					.sink(
						receiveCompletion: { [weak self] completion in
							switch completion {
								case .finished: return
								case .failure(let error):
								self?.isUpdatingName = false
								self?.banner = BannerData(error: error)
							}
						},
						receiveValue: { [weak self] updatedFullName in
							guard let self = self else { return }
							self.user.fullName = updatedFullName
							self.isUpdatingName = false
							AppState.updateAppState(with: .userUpdated(self.user))
							withAnimation(.easeInOut(duration: 0.5)) {
								self.isShowingSettings = false
							}
						}
					)
					.store(in: &cancellables)
			} else {
				self.isUpdatingName = false
			}
		}
		
		func requestDeleteSheet() {
			if isBiometricSuccessful() {
				self.setSheet(.deleteAccount)
			}
		}
		
		@objc func lockKey() {
			self.isSecretKeyLocked = true
		}
		
		func unlockKey() {
			if self.isBiometricSuccessful() {
				self.isSecretKeyLocked = false
			}
		}
		
		private func isBiometricSuccessful() -> Bool {
		#if targetEnvironment(simulator)
			return true
		#else
			let context = LAContext()
			var error: NSError?
			
			// check whether biometric authentication is possible
			if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
				let reason = "Your biometric unlocks your secret key"
				context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
					if success {
						DispatchQueue.main.async {
							return true
						}
					} else {
						DispatchQueue.main.async {
							self.banner = BannerData(detail: "Could not validate your biometric", type: .error)
						}
						return false
					}
				}
			} else {
				// no biometrics
				DispatchQueue.main.async {
					self.banner = BannerData(detail: "Configure your biometric in your device settings to access your secret key", type: .error)
				}
				return false
			}
		#endif
		}
	}
}
