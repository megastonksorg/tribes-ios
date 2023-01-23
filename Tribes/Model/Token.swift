//
//  Token.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-05.
//

import Foundation

struct Token: Codable {
	let jwt: String
	let refresh: String
}
