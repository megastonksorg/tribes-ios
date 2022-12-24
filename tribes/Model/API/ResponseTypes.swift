//
//  SuccessResponse.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-08-23.
//

import Foundation

struct SuccessResponse: Codable {
	let success: Bool
}

struct EmptyResponse: Codable {
	
}

struct ErrorResponse: Codable {
	let message: String
}
