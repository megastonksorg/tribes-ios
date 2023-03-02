//
//  Binding+Extensions.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-02.
//

import SwiftUI

extension Binding where Value == String {
	func max(_ limit: Int) -> Self {
		if self.wrappedValue.count > limit {
			DispatchQueue.main.async {
				self.wrappedValue = String(self.wrappedValue.dropLast())
			}
		}
		return self
	}
}
