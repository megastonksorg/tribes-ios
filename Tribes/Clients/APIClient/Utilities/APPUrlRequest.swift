//
//  APPUrlRequest.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-05.
//

import Foundation

struct APPUrlRequest {
#if DEBUG
	let domain = "megastonksdev.azurewebsites.net"
#else
	let domain = "megastonksprod.azurewebsites.net"
#endif
	
	let token: Token?
	let httpMethod: HTTPMethod
	let pathComponents: [String]
	let query: [URLQueryItem]
	let body: Encodable?
	
	var urlRequest: URLRequest {
		get throws {
			let baseUrl = URL(string: "https://\(domain)/")
			guard var url = baseUrl else { throw AppError.apiClientError(.invalidURL) }
			for pathComponent in pathComponents {
				url.appendPathComponent(pathComponent)
			}
			var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
			components?.queryItems = query
			guard let url = components?.url else { throw AppError.apiClientError(.invalidURL) }
			
			var request = URLRequest(url: url)
			request.httpMethod = httpMethod.rawValue
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			
			if let token = token {
				request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
			}
			
			if let body = body, httpMethod != .get {
				request.httpBody = try JSONEncoder().encode(body)
			}
			
			return request
		}
	}
	
	init(
		token: Token?,
		httpMethod: HTTPMethod,
		pathComponents: [String],
		query: [URLQueryItem] = [],
		body: Encodable? = nil
	) {
		self.token = token
		self.httpMethod = httpMethod
		self.pathComponents = pathComponents
		self.query = query
		self.body = body
	}
}
