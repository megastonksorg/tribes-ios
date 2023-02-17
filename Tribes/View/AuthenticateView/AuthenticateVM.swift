//
//  AuthenticateVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-30.
//

import Combine
import Foundation

extension AuthenticateView {
	@MainActor class ViewModel: ObservableObject {
		enum Context {
			case signUp
			case signIn
		}
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		let context: Context
		@Published var user: User
		
		@Published var isLoading: Bool = false
		@Published var isShowingAlert: Bool = false
		@Published var banner: BannerData?
		
		var alertDetail: String {
			let baseDetail: String = "Cancelling authentication will bring you back to the welcome screen"
			switch context {
			case .signUp: return baseDetail + ". Your account creation will be saved"
			case .signIn: return baseDetail
			}
		}
		
		//Clients
		let apiClient = APIClient.shared
		let keychainClient = KeychainClient.shared
		let walletClient = WalletClient.shared
		
		init(context: Context, user: User) {
			self.context = context
			self.user = user
		}
		
		func copyAddress() {
			PasteboardClient.shared.copyText(user.walletAddress)
			self.banner = BannerData(detail: AppConstants.addressCopied, type: .success)
		}
		
		func cancel() {
			FeedbackClient.shared.light()
			self.isShowingAlert = true
		}
		
		func alertYesTapped() {
			AppRouter.popToRoot(stack: .welcome())
			AppState.updateAppState(with: .changeAppMode(.welcome(WelcomePageView.ViewModel())))
		}
		
		func authenticate() {
			self.isLoading = true
			guard
				let rsaKeys = RSAKeys.generateRandomRSAKeyPair(),
				let privateKeyData = rsaKeys.privateKey.key.exportToData(),
				let publicKeyData = rsaKeys.publicKey.key.exportToData()
			else {
				self.banner = BannerData(error: .rawError("Something went wrong. Please try that again"))
				self.isLoading = false
				return
			}
			let privateKeyString = privateKeyData.base64EncodedString()
			let publicKeyString = publicKeyData.base64EncodedString()
			switch self.walletClient.signMessage(message: publicKeyString) {
				case .success(let signedMessage):
				let authenticateModel = AuthenticateRequest(walletAddress: user.walletAddress, messagePublicKey: publicKeyString, signature: signedMessage.signature)
				self.apiClient.authenticateUser(model: authenticateModel)
					.receive(on: DispatchQueue.main)
					.sink(
						receiveCompletion: { [weak self] completion in
							switch completion {
								case .finished: return
								case .failure(let error):
									self?.isLoading = false
									self?.banner = BannerData(error: error)
							}
						},
						receiveValue: { [weak self] authenticateResponse in
							let user: User = User(
								walletAddress: authenticateResponse.walletAddress,
								fullName: authenticateResponse.fullName,
								profilePhoto: authenticateResponse.profilePhoto,
								currency: authenticateResponse.currency,
								acceptTerms: authenticateResponse.acceptTerms,
								isOnboarded: authenticateResponse.isOnboarded
							)
							self?.keychainClient.set(key: .user, value: user)
							self?.keychainClient.set(key: .token, value: Token(jwt: authenticateResponse.jwtToken, refresh: authenticateResponse.refreshToken))
							self?.keychainClient.set(key: .messageKey, value: MessageKey(privateKey: privateKeyString, publicKey: publicKeyString))
							self?.isLoading = false
							AppState.updateAppState(with: .changeAppMode(.home(HomeView.ViewModel(user: user))))
						}
					)
					.store(in: &cancellables)
				case .failure(let error):
					self.isLoading = false
					self.banner = BannerData(error: error)
			}
		}
	}
}
