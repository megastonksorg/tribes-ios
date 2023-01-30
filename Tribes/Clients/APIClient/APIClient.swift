//
//  APIClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-27.
//

import Combine
import Foundation

typealias APIClientError = AppError.APIClientError

protocol APIRequests {
	//Authentication
	func requestAuthentication() -> AnyPublisher<String, APIClientError>
	func doesAccountExist(for walletAddress: String) -> AnyPublisher<SuccessResponse, APIClientError>
	func authenticateUser(model: AuthenticateRequest) -> AnyPublisher<AuthenticateResponse, APIClientError>
	func registerUser(model: RegisterRequest) -> AnyPublisher<RegisterResponse, APIClientError>
	func uploadImage(imageData: Data) -> AnyPublisher<URL, APIClientError>
	//Tribe
	func getTribes() -> AnyPublisher<[Tribe], APIClientError>
}

final class APIClient: APIRequests {
	
	static let shared: APIClient = APIClient()

	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	
	let decoder: JSONDecoder = JSONDecoder()
	let keychainClient: KeychainClient = KeychainClient.shared
	
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
	func getTribes() -> AnyPublisher<[Tribe], APIClientError> {
		let getTribesRequest = APPUrlRequest(
			httpMethod: .get,
			pathComponents: ["tribe"],
			requiresAuth: true
		)
		return apiRequest(appRequest: getTribesRequest, output: [Tribe].self)
	}
	
	private func apiRequest<Output: Decodable>(appRequest: APPUrlRequest, output: Output.Type) -> AnyPublisher<Output, APIClientError> {
		do {
			return try urlRequest(urlRequest: appRequest.urlRequest)
				.retry(1)
				.decode(type: output, decoder: self.decoder)
				.mapError{ error in
					if let error = error as? AppError.APIClientError {
						if error == .authExpired {
							self.refreshAuth()
						}
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
	
	private func refreshAuth() {
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
		let urlRequest: APPUrlRequest = APPUrlRequest(httpMethod: .post, pathComponents: ["account", "refresh"])
		apiRequest(appRequest: urlRequest, output: AuthenticateResponse.self)
			.sink(receiveCompletion: { _ in
				
			}, receiveValue: { [weak self] authResponse in
				let token = Token(jwt: authResponse.jwtToken, refresh: authResponse.refreshToken)
				let user = User(
					walletAddress: authResponse.walletAddress,
					fullName: authResponse.fullName,
					profilePhoto: authResponse.profilePhoto,
					currency: authResponse.currency,
					acceptTerms: authResponse.acceptTerms,
					isOnboarded: authResponse.isOnboarded
				)
				self?.keychainClient.set(key: .token, value: token)
				self?.keychainClient.set(key: .user, value: user)
			})
			.store(in: &cancellables)
	}
	
	private func urlRequest(urlRequest: URLRequest) -> AnyPublisher<Data, Error> {
		return URLSession.shared.dataTaskPublisher(for: urlRequest)
			.validateStatusCode()
			.map(\.data)
			.eraseToAnyPublisher()
	}
}
