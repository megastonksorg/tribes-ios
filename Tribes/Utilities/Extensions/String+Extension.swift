//
//  String+Extension.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-11.
//

import SwiftUI

extension String {	
	var isValidName: Bool {
		do
		{
			let regex = try NSRegularExpression(
				pattern: "^[\\p{L}'-][\\p{L}' -]{\(SizeConstants.fullNameLowerLimit),\(SizeConstants.fullNameHigherLimit)}$",
				options: .caseInsensitive
			)
			if regex.matches(in: self, options: [], range: NSMakeRange(0, self.count)).count > 0 {return true}
		}
		catch {}
		return false
	}
	
	var isTribeNameValid: Bool {
		(4...SizeConstants.tribeNameLimit).contains(self.trimmingCharacters(in: .whitespacesAndNewlines).count)
	}
	
	var unwrappedContentUrl: URL { URL(string: self) ?? URL(string: "https://invalidContent.com")! }
	
	var date: Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
		dateFormatter.timeZone = TimeZone.current
		return dateFormatter.date(from: self)
	}
	
	func utcToCurrent() -> String {
		let stringFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = stringFormat
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		
		let localDate = dateFormatter.date(from: self)
		dateFormatter.timeZone = TimeZone.current
		dateFormatter.dateFormat = stringFormat
		
		return dateFormatter.string(from: localDate ?? Date.now)
	}
}
