//
//  CGFloat+Extensions.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-09.
//

import Foundation

extension CGFloat {
	func getTribeNameSize() -> Self {
		switch self {
		case 0..<100: return 12
		case 100..<250: return 15
		case 250..<400: return 18
		default: return 22
		}
	}
}
