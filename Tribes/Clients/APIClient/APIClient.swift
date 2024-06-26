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
	func getMediaData(url: URL) async -> Data?
	//Account
	func doesAccountExist(for walletAddress: String) -> AnyPublisher<SuccessResponse, APIClientError>
	func authenticateUser(model: AuthenticateRequest) -> AnyPublisher<AuthenticateResponse, APIClientError>
	func registerUser(model: RegisterRequest) -> AnyPublisher<RegisterResponse, APIClientError>
	func updateName(fullName: String) -> AnyPublisher<String, APIClientError>
	func updateProfilePhoto(photoUrl: URL) -> AnyPublisher<URL, APIClientError>
	func deleteAccount() -> AnyPublisher<EmptyResponse, APIClientError>
	//Media
	func uploadImage(imageData: Data) -> AnyPublisher<URL, APIClientError>
	func uploadVideo(videoData: Data) -> AnyPublisher<URL, APIClientError>
	//Message
	func getMessage(messageId: String) -> AnyPublisher<MessageResponse, APIClientError>
	func getMessages(tribeId: Tribe.ID) -> AnyPublisher<[MessageResponse], APIClientError>
	func deleteMessage(messageId: Message.ID) -> AnyPublisher<SuccessResponse, APIClientError>
	func getMessageViewers(messageId: Message.ID) -> AnyPublisher<[String], APIClientError>
	func markMessageAsViewed(messageId: Message.ID) -> AnyPublisher<EmptyResponse, APIClientError>
	func postMessage(model: PostMessage) -> AnyPublisher<MessageResponse, APIClientError>
	func getAllowedTeaRecipients() -> AnyPublisher<[String], APIClientError>
	//Tribe
	func createTribe(name: String) -> AnyPublisher<Tribe, APIClientError>
	func getTribes() -> AnyPublisher<[Tribe], APIClientError>
	func inviteToTribe(tribeID: Tribe.ID, code: String) -> AnyPublisher<SuccessResponse, APIClientError>
	func joinTribe(pin: String, code: String) -> AnyPublisher<Tribe, APIClientError>
	func leaveTribe(tribeID: Tribe.ID) -> AnyPublisher<SuccessResponse, APIClientError>
	func removeMember(tribeID: Tribe.ID, memberId: TribeMember.ID) -> AnyPublisher<SuccessResponse, APIClientError>
	func blockMember(tribeID: Tribe.ID, memberId: TribeMember.ID) -> AnyPublisher<SuccessResponse, APIClientError>
	func updateTribeName(tribeID: Tribe.ID, name: String) -> AnyPublisher<String, APIClientError>
	
	func updateDeviceToken(_ token: String)
	func updateDeviceBadge(_ count: Int)
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
	
	func updateDeviceToken(_ token: String) {
		self.updateDeviceToken(token: token)
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { _ in }
			)
			.store(in: &self.cancellables)
	}
	
	func updateDeviceBadge(_ count: Int) {
		self.updateDeviceBadge(count: count)
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { _ in }
			)
			.store(in: &self.cancellables)
	}
	
	func getMediaData(url: URL) async -> Data? {
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
							continuation.resume(with: .success(data))
						}
					)
					.store(in: &self.cancellables)
			}
		}
	}
	
	//Account
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
	
	func updateName(fullName: String) -> AnyPublisher<String, APIClientError> {
		let updateNameRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["account", "updateName"],
			query: [URLQueryItem(name: "fullName", value: fullName)],
			requiresAuth: true
		)
		return apiRequest(appRequest: updateNameRequest, output: String.self)
	}
	
	func updateProfilePhoto(photoUrl: URL) -> AnyPublisher<URL, APIClientError> {
		let updatePhotoRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["account", "updateProfilePhoto"],
			query: [URLQueryItem(name: "photoUrl", value: photoUrl.absoluteString)],
			requiresAuth: true
		)
		return apiRequest(appRequest: updatePhotoRequest, output: URL.self)
	}
	
	func deleteAccount() -> AnyPublisher<EmptyResponse, APIClientError> {
		let deleteAccountRequest = APPUrlRequest(
			httpMethod: .delete,
			pathComponents: ["account"],
			requiresAuth: true
		)
		return apiRequest(appRequest: deleteAccountRequest, output: EmptyResponse.self)
	}
	
	//Media
	func uploadImage(imageData: Data) -> AnyPublisher<URL, APIClientError> {
		let imageUploadRequest = APPUrlRequest(
			httpMethod: .put,
			pathComponents: ["mediaUpload", "image"],
			body: imageData
		)
		return apiRequest(appRequest: imageUploadRequest, output: URL.self)
	}
	
	func uploadVideo(videoData: Data) -> AnyPublisher<URL, APIClientError> {
		let videoUploadRequest = APPUrlRequest(
			httpMethod: .put,
			pathComponents: ["mediaUpload", "video"],
			body: videoData
		)
		return apiRequest(appRequest: videoUploadRequest, output: URL.self)
	}
	
	//Message
	func getMessage(messageId: String) -> AnyPublisher<MessageResponse, APIClientError> {
		let getMessageRequest = APPUrlRequest(
			httpMethod: .get,
			pathComponents: ["message", "id"],
			query: [URLQueryItem(name: "messageId", value: messageId)],
			requiresAuth: true
		)
		return apiRequest(appRequest: getMessageRequest, output: MessageResponse.self)
	}
	
	func getMessages(tribeId: Tribe.ID) -> AnyPublisher<[MessageResponse], APIClientError> {
		let getMessagesRequest = APPUrlRequest(
			httpMethod: .get,
			pathComponents: ["message"],
			query: [URLQueryItem(name: "tribeId", value: tribeId)],
			requiresAuth: true
		)
		return apiRequest(appRequest: getMessagesRequest, output: [MessageResponse].self)
	}
	
	func deleteMessage(messageId: Tribe.ID) -> AnyPublisher<SuccessResponse, APIClientError> {
		let deleteMessageRequest = APPUrlRequest(
			httpMethod: .delete,
			pathComponents: ["message"],
			query: [URLQueryItem(name: "messageId", value: messageId)],
			requiresAuth: true
		)
		return apiRequest(appRequest: deleteMessageRequest, output: SuccessResponse.self)
	}
	
	func getMessageViewers(messageId: Message.ID) -> AnyPublisher<[String], APIClientError> {
		let getMessageViewersRequest = APPUrlRequest(
			httpMethod: .get,
			pathComponents: ["message", "viewers"],
			query: [URLQueryItem(name: "messageId", value: messageId)],
			requiresAuth: true
		)
		return apiRequest(appRequest: getMessageViewersRequest, output: [String].self)
	}
	
	func markMessageAsViewed(messageId: Message.ID) -> AnyPublisher<EmptyResponse, APIClientError> {
		let markMessageAsViewedRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["message", "markAsViewed"],
			query: [URLQueryItem(name: "messageId", value: messageId)],
			requiresAuth: true
		)
		return apiRequest(appRequest: markMessageAsViewedRequest, output: EmptyResponse.self)
	}
	
	func postMessage(model: PostMessage) -> AnyPublisher<MessageResponse, APIClientError> {
		let postMessageRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["message"],
			body: model,
			requiresAuth: true
		)
		return apiRequest(appRequest: postMessageRequest, output: MessageResponse.self)
	}
	
	func getAllowedTeaRecipients() -> AnyPublisher<[String], APIClientError> {
		let getAllowedTeaRecipientsRequest = APPUrlRequest(
			httpMethod: .get,
			pathComponents: ["message", "allowedTeaRecipients"],
			requiresAuth: true
		)
		return apiRequest(appRequest: getAllowedTeaRecipientsRequest, output: [String].self)
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
	
	func removeMember(tribeID: Tribe.ID, memberId: TribeMember.ID) -> AnyPublisher<SuccessResponse, APIClientError> {
		let removeMemberRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["tribe", "remove"],
			query: [
				URLQueryItem(name: "id", value: tribeID),
				URLQueryItem(name: "memberId", value: memberId)
			],
			requiresAuth: true
		)
		return apiRequest(appRequest: removeMemberRequest, output: SuccessResponse.self)
	}
	
	func blockMember(tribeID: Tribe.ID, memberId: TribeMember.ID) -> AnyPublisher<SuccessResponse, APIClientError> {
		let blockMemberRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["tribe", "block"],
			query: [
				URLQueryItem(name: "id", value: tribeID),
				URLQueryItem(name: "memberId", value: memberId)
			],
			requiresAuth: true
		)
		return apiRequest(appRequest: blockMemberRequest, output: SuccessResponse.self)
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
	
	private func updateDeviceToken(token: String) -> AnyPublisher<EmptyResponse, APIClientError> {
		let updateDeviceTokenRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["account", "updateAppleDeviceToken"],
			query: [URLQueryItem(name: "deviceToken", value: token)],
			requiresAuth: true
		)
		return apiRequest(appRequest: updateDeviceTokenRequest, output: EmptyResponse.self)
	}
	
	private func updateDeviceBadge(count: Int) -> AnyPublisher<EmptyResponse, APIClientError> {
		let updateDeviceBadgeRequest = APPUrlRequest(
			httpMethod: .post,
			pathComponents: ["account", "deviceBadge"],
			query: [URLQueryItem(name: "count", value: "\(count)")],
			requiresAuth: true
		)
		return apiRequest(appRequest: updateDeviceBadgeRequest, output: EmptyResponse.self)
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
