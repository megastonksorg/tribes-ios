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
			let regex = try NSRegularExpression(pattern: "^[\\p{L}'-][\\p{L}' -]{2,30}$", options: .caseInsensitive)
			if regex.matches(in: self, options: [], range: NSMakeRange(0, self.count)).count > 0 {return true}
		}
		catch {}
		return false
	}
	var isTribeNameValid: Bool {
		self.count <= SizeConstants.tribeNameLimit
	}
}
