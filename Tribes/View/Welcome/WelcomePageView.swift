//
//  WelcomePageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-05-31.
//

import SwiftUI

struct WelcomePageView: View {
	@StateObject var viewModel: ViewModel
	
	@EnvironmentObject var appRouter: AppRouter
	
	init(viewModel: ViewModel) {
		UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.app.secondary)
		UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.app.secondary).withAlphaComponent(0.4)
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		NavigationStack(path: $appRouter.welcomeStack) {
			VStack(spacing: 0) {
				TabView {
					ForEach(OnBoardingPageView.Page.allCases) { page in
						OnBoardingPageView(page: page)
					}
				}
				.tabViewStyle(.page(indexDisplayMode: .never))
				
				Rectangle()
					.frame(height: 40)
				
				Group {
					Button(action: { viewModel.generateNewWallet() }) {
						Text("Create a new account")
					}
					.buttonStyle(ExpandedButtonStyle())
					
					Button(action: { viewModel.importWallet() }) {
						Text("Login to account")
					}
					.buttonStyle(ExpandedButtonStyle(invertedStyle: true))
				}
				.textCase(.uppercase)
				.padding(.bottom)
			}
			.background(AppBackgroundView())
			.overlay(isShown: viewModel.isLoading) {
				AppProgressView()
			}
			.banner(data: $viewModel.banner)
			.navigationTitle("")
			.navigationDestination(for: AppRouter.Route.WelcomeStack.self) { route in
				Group {
					switch route {
						case .createWallet:
							NewSecretPhraseView()
								.environmentObject(appRouter)
						case .importWallet:
							ImportSecretPhraseView()
								.environmentObject(appRouter)
						case .verifySecretPhrase:
							VerifySecretPhraseView()
								.environmentObject(appRouter)
					case .createProfile(let shouldShowHint, let walletAddress):
						let viewModel = ProfileSettingsView.ViewModel(
							mode: .creation,
							shouldShowAccountNotFoundHint: shouldShowHint,
							walletAddress: walletAddress
						)
						ProfileSettingsView(viewModel: viewModel)
							.environmentObject(appRouter)
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("")
			}
		}
		.tint(Color.app.tertiary)
	}
}

struct WelcomePageView_Previews: PreviewProvider {
	static var previews: some View {
		WelcomePageView(viewModel: WelcomePageView.ViewModel())
			.environmentObject(AppRouter())
	}
}
