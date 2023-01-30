//
//  TokenManager.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-29.
//

import Foundation

class TokenManager {
	private var isRefreshing: Bool = false
	private let keychainClient: KeychainClient = KeychainClient.shared
	static let shared: TokenManager = TokenManager()
	
	func refreshToken() {
		if !self.isRefreshing {
			Task {
				self.isRefreshing = true
				if let token = keychainClient.get(key: .token), let cookie = HTTPCookie(properties: [
					.domain: APPUrlRequest.domain,
					.path: "/",
					.name: "refreshToken",
					.value: token.refresh,
					.secure: "FALSE",
					.discard: "TRUE"
				]) {
					HTTPCookieStorage.shared.setCookie(cookie)
				}
				let urlRequest: URLRequest = try! APPUrlRequest(httpMethod: .post, pathComponents: ["account", "refresh"]).urlRequest
				
				let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
				
				let authResponse = try JSONDecoder().decode(AuthenticateResponse.self, from: data)
				let token = Token(jwt: authResponse.jwtToken, refresh: authResponse.refreshToken)
				let user = User(
					walletAddress: authResponse.walletAddress,
					fullName: authResponse.fullName,
					profilePhoto: authResponse.profilePhoto,
					currency: authResponse.currency,
					acceptTerms: authResponse.acceptTerms,
					isOnboarded: authResponse.isOnboarded
				)
				self.keychainClient.set(key: .token, value: token)
				self.keychainClient.set(key: .user, value: user)
				self.isRefreshing = false
			}
		}
	}
}
