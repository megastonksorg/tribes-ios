//
//  AuthenticateVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-30.
//

import Combine

extension AuthenticateView {
	@MainActor class ViewModel: ObservableObject {
		@Published var user: User
		
		@Published var isShowingAlert: Bool = false
		@Published var banner: BannerData?
		
		init(user: User) {
			self.user = user
		}
		
		func copyAddress() {
			PasteboardClient.shared.copyText(user.walletAddress)
			banner = BannerData(detail: "Address copied to clipboard", type: .success)
		}
		
		func cancel() {
			FeedbackClient.shared.light()
			self.isShowingAlert = true
		}
		
		func alertYesTapped() {
			AppRouter.popToRoot(stack: .route1())
			AppState.updateAppState(with: .changeAppMode(.welcome(WelcomePageView.ViewModel())))
		}
		
		func authenticate() {
			
		}
	}
}
