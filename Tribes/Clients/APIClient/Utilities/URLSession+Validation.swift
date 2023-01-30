//
//  URLSession+Validation.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-05.
//

import Foundation
import Combine

extension URLSession.DataTaskPublisher {
	func validateStatusCode() -> AnyPublisher<Output, Error> {
		return tryMap { data, response in
			if let response = response as? HTTPURLResponse, (400..<600).contains(response.statusCode) {
				if response.statusCode == 401 {
					TokenManager.shared.refreshToken()
					throw AppError.APIClientError.authExpired
				}
				if let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
					throw AppError.APIClientError.httpError(statusCode: response.statusCode, data: Data(errorMessage.message.utf8))
				}
				else {
					throw AppError.APIClientError.httpError(statusCode: response.statusCode, data: data)
				}
			} else {
				return (data, response)
			}
		}
		.retry(times: 4, if: { error in
			if let error = error as? AppError.APIClientError {
				if error == .authExpired {
					return true
				}
			}
			return false
		})
		.eraseToAnyPublisher()
	}
}
