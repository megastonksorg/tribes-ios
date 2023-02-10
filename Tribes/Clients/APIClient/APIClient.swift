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
	func updateTribeName(tribeID: Tribe.ID, name: String) -> AnyPublisher<String, APIClientError>
}

final class APIClient: APIRequests {
	
	static let shared: APIClient = APIClient()

	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
	
	private let queue = DispatchQueue(label: "com.strikingFinancial.tribes.api.sessionQueue", target: .global())
	
	let decoder: JSONDecoder = JSONDecoder()
	let keychainClient: KeychainClient = KeychainClient.shared
	
	func getImage(url: URL) async -> UIImage? {
		await withCheckedContinuation { continuation in
			queue.async { [weak self] in
				guard let self = self else { return }
				self.urlRequest(urlRequest: URLRequest(url: url))
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
					.store(in: &self.cancellables)
			}
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
	
	func updateTribeName(tribeID: Tribe.ID, name: String) -> AnyPublisher<String, APIClientError> {
		let updateTribeNameRequest = APPUrlRequest(
			httpMethod: .patch,
			pathComponents: ["tribe", "name"],
			query: [
				URLQueryItem(name: "id", value: tribeID),
				URLQueryItem(name: "name", value: name)
			],
			requiresAuth: true
		)
		return apiRequest(appRequest: updateTribeNameRequest, output: String.self)
	}
	
	private func apiRequest<Output: Decodable>(appRequest: APPUrlRequest, output: Output.Type) -> AnyPublisher<Output, APIClientError> {
		do {
			return try urlRequest(urlRequest: appRequest.urlRequest)
				.catch { error -> AnyPublisher<Data, Error> in
					let failedPublisher: AnyPublisher<Data, Error> = Fail(error: error).eraseToAnyPublisher()
					if let error  = error as? APIClientError {
						if error == .authExpired {
							return TokenManager.shared.refreshToken()
								.flatMap { isSuccess -> AnyPublisher<Data, Error> in
									let request = try! appRequest.urlRequest
									if isSuccess {
										return self.urlRequest(urlRequest: request)
											.eraseToAnyPublisher()
									} else {
										return failedPublisher
									}
								}
								.eraseToAnyPublisher()
						} else {
							return failedPublisher
						}
					} else {
						return failedPublisher
					}
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
	
	func urlRequest(urlRequest: URLRequest) -> AnyPublisher<Data, Error> {
		return URLSession.shared.dataTaskPublisher(for: urlRequest)
			.validateStatusCode()
			.map(\.data)
			.eraseToAnyPublisher()
	}
}
