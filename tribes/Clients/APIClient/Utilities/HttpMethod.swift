//
//  HttpMethod.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-05.
//

import Foundation

struct HTTPMethod: Equatable, RawRepresentable {
	static let get = HTTPMethod(rawValue: "GET")
	static let post = HTTPMethod(rawValue: "POST")
	static let put = HTTPMethod(rawValue: "PUT")
	static let patch = HTTPMethod(rawValue: "PATCH")
	static let delete = HTTPMethod(rawValue: "DELETE")
	
	var rawValue: String
	
	init(rawValue: String) {
		self.rawValue = rawValue
	}
}
