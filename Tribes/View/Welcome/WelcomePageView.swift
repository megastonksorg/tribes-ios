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
	
	@State var currentOnboardingPage: OnBoardingPageView.Page = .stayConnected
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		NavigationStack(path: $appRouter.welcomeStack) {
			VStack(spacing: 0) {
				OnBoardingPageView.TextView(text: currentOnboardingPage.header)
					.animation(.easeInOut, value: currentOnboardingPage)
					.opacity(currentOnboardingPage == .stayConnected ? 0.0 : 1.0)
					.padding(.top, 30)
				
				TabView(selection: $currentOnboardingPage) {
					ForEach(OnBoardingPageView.Page.allCases) { page in
						OnBoardingPageView(page: page)
							.id(page)
							.tag(page)
					}
					.introspectScrollView {
						$0.bounces = false
					}
				}
				.tabViewStyle(.page(indexDisplayMode: .never))
				
				Rectangle()
					.fill(Color.clear)
					.frame(height: 20)
				
				currentPageIndexView(currentPage: currentOnboardingPage)
				
				Rectangle()
					.fill(Color.clear)
					.frame(height: 40)
				
				Group {
					Button(action: { viewModel.generateNewWallet() }) {
						Text("Create a new account")
					}
					.buttonStyle(.expanded)
					
					Button(action: { viewModel.importWallet() }) {
						Text("Login to account")
					}
					.buttonStyle(.expanded(invertedStyle: true))
				}
				.textCase(.uppercase)
				.padding(.bottom)
			}
			.background(AppBackgroundView())
			.safeAreaInset(edge: .top) {
				TextView(AppConstants.appName, style: .appTitle)
					.padding(.top)
			}
			.overlay(isShown: viewModel.isLoading) {
				AppProgressView()
			}
			.banner(data: $viewModel.banner)
			.navigationTitle("")
			.navigationDestination(for: AppRouter.Route.WelcomeStack.self) { route in
				Group {
					switch route {
						case .createWallet:
							NewSecretKeyView()
								.environmentObject(appRouter)
						case .importWallet:
							ImportSecretKeyView()
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
	
	@ViewBuilder
	func currentPageIndexView(currentPage: OnBoardingPageView.Page) -> some View {
		HStack {
			ForEach(OnBoardingPageView.Page.allCases) { page in
				ZStack {
					Circle()
						.stroke(Color.app.secondary)
					Circle()
						.fill(Color.app.secondary)
						.opacity(page == currentPage ? 1.0 : 0.0)
						.animation(.easeInOut, value: currentPage)
				}
				.frame(dimension: 10)
				.id(page)
			}
		}
	}
}

struct WelcomePageView_Previews: PreviewProvider {
	static var previews: some View {
		WelcomePageView(viewModel: WelcomePageView.ViewModel())
			.environmentObject(AppRouter())
	}
}
