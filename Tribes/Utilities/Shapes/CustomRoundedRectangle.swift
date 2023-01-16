//
//  CustomRoundedRectangle.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-16.
//

import Foundation
import SwiftUI

struct CustomRoundedRectangle: Shape {
	let cornerRadius: CGFloat
	let corners: UIRectCorner
	
	public func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(
			roundedRect: rect,
			byRoundingCorners: corners,
			cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
		)
		return Path(path.cgPath)
	}
}
