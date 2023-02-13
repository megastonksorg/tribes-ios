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
		
		//Clients
		let apiClient = APIClient.shared
		let keychainClient = KeychainClient.shared
		let walletClient = WalletClient.shared
		
		let context: Context
		@Published var user: User
		
		@Published var isLoading: Bool = false
		@Published var isShowingAlert: Bool = false
		@Published var banner: BannerData?
		
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
			self.apiClient.requestAuthentication()
				.flatMap { [unowned self] messageToSign -> AnyPublisher<AuthenticateResponse, APIClientError> in
					switch self.walletClient.signMessage(message: messageToSign) {
					case .success(let signedMessage):
						let authenticateModel = AuthenticateRequest(walletAddress: user.walletAddress, signature: signedMessage.signature)
						return self.apiClient.authenticateUser(model: authenticateModel)
					case .failure(let error):
						self.banner = BannerData(error: error)
						return Empty().eraseToAnyPublisher()
					}
				}
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
						self?.isLoading = false
						self?.keychainClient.set(key: .user, value: user)
						self?.keychainClient.set(key: .token, value: Token(jwt: authenticateResponse.jwtToken, refresh: authenticateResponse.refreshToken))
						AppState.updateAppState(with: .changeAppMode(.home(HomeView.ViewModel(user: user))))
					}
				)
				.store(in: &cancellables)
		}
	}
}
