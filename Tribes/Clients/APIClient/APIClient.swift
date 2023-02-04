//
//  APIClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-27.
//

import Combine
import Foundation
import UIKit

typealias APIClientError = AppError.APIClientError

protocol APIRequests {
	func getImage(url: URL) async -> UIImage?
	//Authentication
	func requestAuthentication() -> AnyPublisher<String, APIClientError>
	func doesAccountExist(for walletAddress: String) -> AnyPublisher<SuccessResponse, APIClientError>
	func authenticateUser(model: AuthenticateRequest) -> AnyPublisher<AuthenticateResponse, APIClientError>
	func registerUser(model: RegisterRequest) -> AnyPublisher<RegisterResponse, APIClientError>
	func uploadImage(imageData: Data) -> AnyPublisher<URL, APIClientError>
	//Tribe
	func createTribe(name: String) -> AnyPublisher<Tribe, APIClientError>
	func getTribes() -> AnyPublisher<[Tribe], APIClientError>
	func inviteToTribe(tribeID: Tribe.ID, code: String) -> AnyPublisher<SuccessResponse, APIClientError>
	func joinTribe(pin: String, code: String) -> AnyPublisher<Tribe, APIClientError>
	func leaveTribe(tribeID: Tribe.ID) -> AnyPublisher<SuccessResponse, APIClientError>
}

final class APIClient: APIRequests {
	
	static let shared: APIClient = APIClient()

	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	private var isRefreshingToken: Bool = false
	
	let decoder: JSONDecoder = JSONDecoder()
	let keychainClient: KeychainClient = KeychainClient.shared
	
	func getImage(url: URL) async -> UIImage? {
		await withCheckedContinuation { continuation in
			urlRequest(urlRequest: URLRequest(url: url))
				.sink(
					receiveCompletion: { completion in
						switch completion {
						case .finished: return
						case .failure:
							continuation.resume(with: .success(nil))
							return
						}
					},
					receiveValue: { data in
						continuation.resume(with: .success(UIImage(data: data)))
					}
				)
				.store(in: &cancellables)
		}
	}
	
	func requestAuthentication() -> AnyPublisher<String, APIClientError> {
		let authenticationRequest = APPUrlRequest(
			httpMethod: .get,
			pathComponents: ["account", "requestAuthentication"]
		)
		return apiRequest(appRequest: authenticationRequest, output: String.self)
	}
	
	func doesAccountExist(for walletAddress: String) -> AnyPublisher<SuccessResponse, APIClientError> {
		let accountExistsRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["account", "doesAccountExist"],
			query: [URLQueryItem(name: "walletAddress", value: walletAddress)]
		)
		return apiRequest(appRequest: accountExistsRequest, output: SuccessResponse.self)
	}
	
	func authenticateUser(model: AuthenticateRequest) -> AnyPublisher<AuthenticateResponse, APIClientError> {
		let authenticateRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["account", "authenticate"],
			body: model
		)
		return apiRequest(appRequest: authenticateRequest, output: AuthenticateResponse.self)
	}
	
	func registerUser(model: RegisterRequest) -> AnyPublisher<RegisterResponse, APIClientError> {
		let registerRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["account", "register"],
			body: model
		)
		return apiRequest(appRequest: registerRequest, output: RegisterResponse.self)
	}
	
	func uploadImage(imageData: Data) -> AnyPublisher<URL, APIClientError> {
		let imageUploadRequest = APPUrlRequest(
			httpMethod: .put,
			pathComponents: ["mediaUpload", "image"],
			body: imageData
		)
		return apiRequest(appRequest: imageUploadRequest, output: URL.self)
	}
	
	//Tribes
	func createTribe(name: String) -> AnyPublisher<Tribe, APIClientError> {
		let createTribeRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["tribe", "create"],
			query: [URLQueryItem(name: "name", value: name)],
			requiresAuth: true
		)
		return apiRequest(appRequest: createTribeRequest, output: Tribe.self)
	}
	
	func getTribes() -> AnyPublisher<[Tribe], APIClientError> {
		let getTribesRequest = APPUrlRequest(
			httpMethod: .get,
			pathComponents: ["tribe"],
			requiresAuth: true
		)
		return apiRequest(appRequest: getTribesRequest, output: [Tribe].self)
	}
	
	func inviteToTribe(tribeID: Tribe.ID, code: String) -> AnyPublisher<SuccessResponse, APIClientError> {
		let inviteToTribeRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["tribe", "invite"],
			query: [
				URLQueryItem(name: "tribeId", value: tribeID),
				URLQueryItem(name: "code", value: code)
			],
			requiresAuth: true
		)
		return apiRequest(appRequest: inviteToTribeRequest, output: SuccessResponse.self)
	}
	
	func joinTribe(pin: String, code: String) -> AnyPublisher<Tribe, APIClientError> {
		let joinTribeRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["tribe", "join"],
			query: [
				URLQueryItem(name: "pin", value: pin),
				URLQueryItem(name: "code", value: code)
			],
			requiresAuth: true
		)
		return apiRequest(appRequest: joinTribeRequest, output: Tribe.self)
	}
	
	func leaveTribe(tribeID: Tribe.ID) -> AnyPublisher<SuccessResponse, APIClientError> {
		let leaveTribeRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["tribe", "leave"],
			query: [URLQueryItem(name: "id", value: tribeID)],
			requiresAuth: true
		)
		return apiRequest(appRequest: leaveTribeRequest, output: SuccessResponse.self)
	}
	
	private func apiRequest<Output: Decodable>(appRequest: APPUrlRequest, output: Output.Type) -> AnyPublisher<Output, APIClientError> {
		do {
			return try urlRequest(urlRequest: appRequest.urlRequest)
				.catch { error -> AnyPublisher<Data, Error> in
					if let error  = error as? APIClientError {
						if error == .authExpired {
							do {
								if !self.isRefreshingToken {
									self.isRefreshingToken = true
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
									
									return self.urlRequest(urlRequest: tokenRequest)
										.decode(type: AuthenticateResponse.self, decoder: self.decoder)
										.mapError{ $0 as? AppError.APIClientError ?? APIClientError.rawError($0.localizedDescription) }
										.eraseToAnyPublisher()
										.handleEvents(receiveCompletion: { completion in
											switch completion {
											case .finished: return
											case .failure(let error):
												if let error = error as? AppError.APIClientError {
													let expectedDataError: Data = Data("Invalid token".utf8)
													if error == .httpError(statusCode: 400, data: expectedDataError) {
														Task {
															await AppState.updateAppState(with: .logUserOut)
														}
													}
												}
											}
										})
										.flatMap { authResponse -> AnyPublisher<Data, Error> in
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
											let request = try! appRequest.urlRequest
											self.isRefreshingToken = false
											return self.urlRequest(urlRequest: request)
												.eraseToAnyPublisher()
										}
										.eraseToAnyPublisher()
								}
							} catch {
								return Fail(error: error as? APIClientError ?? APIClientError.rawError(error.localizedDescription)).eraseToAnyPublisher()
							}
						}
					}
					return Fail(error: error as? APIClientError ?? APIClientError.rawError(error.localizedDescription)).eraseToAnyPublisher()
				}
				.decode(type: output, decoder: self.decoder)
				.mapError{ error in
					if let error = error as? AppError.APIClientError {
						return error
					}
					else {
						return AppError.APIClientError.rawError(String(describing: error))
					}
				}
				.eraseToAnyPublisher()
		}
		catch let error {
			return Fail(error: AppError.APIClientError.rawError(String(describing: error)))
					.eraseToAnyPublisher()
		}
	}
	
	private func urlRequest(urlRequest: URLRequest) -> AnyPublisher<Data, Error> {
		return URLSession.shared.dataTaskPublisher(for: urlRequest)
			.validateStatusCode()
			.map(\.data)
			.eraseToAnyPublisher()
	}
}
