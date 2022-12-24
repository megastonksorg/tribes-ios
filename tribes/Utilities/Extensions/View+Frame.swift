//
//  View+Frame.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-05-15.
//

import SwiftUI

extension View {
	
	func frame(dimension: CGFloat?, alignment: Alignment = .center) -> some View {
		frame(width: dimension, height: dimension, alignment: alignment)
	}
	
	func frame(size: CGSize?) -> some View {
		frame(width: size?.width, height: size?.height)
	}
	
	func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
	}
	
	func pushOutFrame(alignment: Alignment = .center) -> some View {
		frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
	}
}
