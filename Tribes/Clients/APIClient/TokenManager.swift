//
//  TokenManager.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-08.
//

import Combine
import Foundation

extension APIClient {
	class TokenManager {
		static let shared: TokenManager = TokenManager()
		private let queue = DispatchQueue(label: "com.strikingFinancial.tribes.token.sessionQueue", target: .global())
		
		private let decoder: JSONDecoder = JSONDecoder()
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		private var lastRefreshed: Date?
		
		//Clients
		private let keychainClient: KeychainClient = KeychainClient.shared
		
		func refreshToken() -> Future<Bool, Never> {
			queue.sync {
				return Future { [weak self] promise in
					guard let self = self else { return }
					do {
						if self.lastRefreshed == nil || Date.now.timeIntervalSince(self.lastRefreshed ?? Date.distantPast) > 1.0 { //Only refresh if it has been more than one minute since the last refresh
							if let token = self.keychainClient.get(key: .token), let cookie = HTTPCookie(properties: [
								.domain: APPUrlRequest.domain,
								.path: "/",
								.name: "refreshToken",
								.value: token.refresh,
								.secure: "FALSE",
								.discard: "TRUE"
							]) {
								HTTPCookieStorage.shared.setCookie(cookie)
							}
							let tokenRequest: URLRequest = try APPUrlRequest(httpMethod: .post, pathComponents: ["account", "refresh"]).urlRequest
							
							APIClient.shared.urlRequest(urlRequest: tokenRequest)
								.decode(type: AuthenticateResponse.self, decoder: self.decoder)
								.mapError{ $0 as? AppError.APIClientError ?? APIClientError.rawError($0.localizedDescription) }
								.sink(receiveCompletion: { completion in
									switch completion {
									case .finished: return
									case .failure(let error):
										let expectedDataError: Data = Data("Invalid token".utf8)
										if error == .httpError(statusCode: 400, data: expectedDataError) {
											Task {
												await AppState.updateAppState(with: .logUserOut)
											}
											promise(.success(false))
										}
									}
								}, receiveValue: { authResponse in
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
									self.lastRefreshed = Date.now
									promise(.success(true))
								})
								.store(in: &self.cancellables)
						} else {
							promise(.success(true))
						}
					} catch {
						promise(.success(false))
					}
				}
			}
		}
	}
}