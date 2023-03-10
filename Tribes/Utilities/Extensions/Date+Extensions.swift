//
//  Date+Extensions.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-10.
//

import Foundation

extension Date {
	func timeAgoDisplay() -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .short
		return formatter.localizedString(for: self, relativeTo: Date())
	}
}
