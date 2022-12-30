//
//  AppView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-24.
//

import SwiftUI

struct AppView: View {
	
	@StateObject var appRouter = AppRouter()
	@StateObject var appState = AppState()
	
	init() { NavBarTheme.setup() }
	
	var body: some View {
		Group {
			switch appState.appMode {
				case .welcome(let welcomePageViewModel):
					WelcomePageView(viewModel: welcomePageViewModel)
						.environmentObject(appRouter)
				case .authentication(let authenticationViewModel):
					AuthenticateView(viewModel: authenticationViewModel)
				case .loggedIn:
					EmptyView()
			}
		}
	}
}

struct AppView_Previews: PreviewProvider {
	static var previews: some View {
		AppView()
	}
}
