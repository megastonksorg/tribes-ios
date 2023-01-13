//
//  String+Extension.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-11.
//

import SwiftUI

extension String {
	var isRealWord: Bool {
		if self.isEmpty { return false }
		let checker = UITextChecker()
		let range = NSRange(location: 0, length: self.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: self, range: range, startingAt: 0, wrap: false, language: "en")
		
		return misspelledRange.location == NSNotFound
	}
	
	var isValidName: Bool {
		do
		{
			let regex = try NSRegularExpression(pattern: "^[\\p{L}'-][\\p{L}' -]{2,30}$", options: .caseInsensitive)
			if regex.matches(in: self, options: [], range: NSMakeRange(0, self.count)).count > 0 {return true}
		}
		catch {}
		return false
	}
}
