//
//  URL+Extension.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-06-03.
//

import Foundation

extension URL {
	subscript(queryParam: String) -> String? {
		guard let url = URLComponents(string: self.absoluteString) else { return nil }
		return url.queryItems?.first(where: { $0.name == queryParam })?.value
	}
}
