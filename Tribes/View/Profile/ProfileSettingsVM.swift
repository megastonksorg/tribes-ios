//
//  ProfileSettingsViewModel.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-13.
//

import Combine
import SwiftUI

extension ProfileSettingsView {
	@MainActor class ViewModel: ObservableObject {
		
		//MARK: - Subtypes
		enum Mode {
			case creation
			case editing
		}
		
		enum FocusField {
			case name
		}
		
		//Clients
		let apiClient = APIClient.shared
		
		let mode: ProfileSettingsView.ViewModel.Mode
		
		var walletAddress: String?
		var user: User?
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var image: UIImage?
		@Published var name: String = ""
		
		@Published var isShowingImagePicker: Bool = false
		@Published var isLoading: Bool = false
		
		@Published var banner: BannerData?
		
		var profilePictureTitle: String {
			switch self.mode {
				case .creation: return "Select a profile picture"
				case .editing: return "Change your profile picture"
			}
		}
		
		var nameHintTitle: String {
			switch self.mode {
				case .creation: return "What do your friends and family call you?"
				case .editing: return "What do you want your tribe members to call you?"
			}
		}
		
		var nameValidation: FieldValidation {
			if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return .unknown }
			else {
				if name.trimmingCharacters(in: .whitespacesAndNewlines).isValidName { return .valid }
				else { return .invalid }
			}
		}
		
		var isCompletionAllowed: Bool {
			return nameValidation == .valid && walletAddress != nil && image != nil
		}
		
		init(
			mode: ProfileSettingsView.ViewModel.Mode,
			walletAddress: String? = nil,
			user: User? = nil
		) {
			self.mode = mode
			self.walletAddress = walletAddress
			self.user = user
			
			if let user = user {
				self.name = user.fullName
			}
		}
		
		func selectImageFromLibrary() {
			self.isShowingImagePicker = true
		}
		
		func complete() {
			if isCompletionAllowed {
				self.isLoading = true
				switch self.mode {
					case .editing: return
					case .creation:
						if walletAddress == nil {
							self.banner = BannerData(detail: "Cannot Create user without a valid wallet", type: .warning)
							self.isLoading = false
						}
						guard let walletAddress = self.walletAddress,
							  let image = self.image,
							  let resizedImage = image.resizedTo(megaBytes: 2.0),
							  let croppedImageData = resizedImage.croppedAndScaled(toFill: SizeConstants.profileImageSize).pngData()
						else {
							self.isLoading = false
							return
						}
						
						self.apiClient.uploadImage(imageData: croppedImageData)
							.flatMap { url -> AnyPublisher<RegisterResponse, APIClientError>  in
								let registerRequestModel: RegisterRequest = RegisterRequest(
									walletAddress: walletAddress,
									profilePhoto: url,
									fullName: self.name,
									acceptTerms: true
								)
								
								return self.apiClient.registerUser(model: registerRequestModel)
							}
							.receive(on: DispatchQueue.main)
							.sink(receiveCompletion: { [weak self] completion in
								guard let self = self else { return }
								switch completion {
									case .finished: return
									case .failure(let error):
										self.isLoading = false
										self.banner = BannerData(title: error.title, detail: error.errorDescription ?? "", type: .error)
								}
							}, receiveValue: { registerResponse in
								let user: User = User(
									walletAddress: registerResponse.walletAddress,
									fullName: registerResponse.fullName,
									profilePhoto: registerResponse.profilePhoto,
									currency: registerResponse.currency,
									acceptTerms: registerResponse.acceptTerms,
									isOnboarded: registerResponse.isOnboarded
								)
								self.isLoading = false
								AppState.updateAppState(with: .changeAppMode(.authentication(AuthenticateView.ViewModel(user: user))))
							})
							.store(in: &cancellables)
				}
			}
			else {
				self.banner = BannerData(title: "Missing Information", detail: "Cannot complete your request at this time. Please ensure all fields are valid and an image is selected", type: .info)
			}
		}
	}
}
