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
		enum FocusField: String, Hashable, Identifiable {
			case editFullName
			
			var id: String { self.rawValue }
		}
		
		enum Sheet: Equatable {
			case imagePicker
			case logout
			case deleteAccount
		}
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		let phrase: IdentifiedArrayOf<MnemonicWord>
		
		@Published var editFullNameText: String = ""
		@Published var editImage: UIImage?
		@Published var user: User
		
		@Published var banner: BannerData?
		@Published var isSecretKeyLocked: Bool = true
		@Published var isShowingSettings: Bool = false
		@Published var isUploadingImage: Bool = false
		@Published var sheet: Sheet?
		
		var isUpdateButtonEnabled: Bool {
			let trimmedName = editFullNameText.trimmingCharacters(in: .whitespacesAndNewlines)
			if trimmedName.isValidName {
				return trimmedName != user.fullName.trimmingCharacters(in: .whitespacesAndNewlines) || editImage != nil
			}
			return false
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
		
		func setEditFullNameText(_ text: String) {
			if text.trimmingCharacters(in: .whitespacesAndNewlines).count < SizeConstants.fullNameHigherLimit {
				self.editFullNameText = text
			}
		}
		
		func setSheet(_ sheet: Sheet?) {
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
			guard editFullNameText.isValidName else { return }
			if editImage != nil {
				self.isUploadingImage = true
				guard let resizedImage = self.editImage?.resizedTo(megaBytes: SizeConstants.imageMaxSizeInMb),
					  let croppedImageData = resizedImage.croppedAndScaled(toFill: SizeConstants.profileImageSize).pngData() else {
					self.banner = BannerData(detail: "Could not scale image. Please select a different image", type: .error)
					self.isUploadingImage = false
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
						self.isUploadingImage = false
						self.editImage = nil
						self.user.profilePhoto = photoUrlResponse
						AppState.updateAppState(with: .userUpdated(self.user))
						self.isShowingSettings = false
					})
					.store(in: &cancellables)
			}
			if editFullNameText.trimmingCharacters(in: .whitespacesAndNewlines) != user.fullName.trimmingCharacters(in: .whitespacesAndNewlines) {
				apiClient.updateName(fullName: editFullNameText)
					.receive(on: DispatchQueue.main)
					.sink(
						receiveCompletion: { [weak self] completion in
							switch completion {
								case .finished: return
								case .failure(let error):
								self?.banner = BannerData(error: error)
							}
						},
						receiveValue: { [weak self] updatedFullName in
							guard let self = self else { return }
							self.user.fullName = updatedFullName
							AppState.updateAppState(with: .userUpdated(self.user))
						}
					)
					.store(in: &cancellables)
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
