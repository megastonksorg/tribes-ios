//
//  View+Extensions.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-15.
//

import SwiftUI

extension View {
	func banner(data: Binding<BannerData?>) -> some View {
		self.modifier(BannerViewModifier(data: data))
	}
	
	func disableAutoCorrection(isNameField: Bool) -> some View {
		self
			.keyboardType(isNameField ? .alphabet : .default)
			.disableAutocorrection(true)
	}
	
	func visible(_ isVisible: Bool) -> some View {
		opacity(isVisible ? 1 : 0)
	}
	
	func dropShadow() -> some View {
		shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
	}
	
	func styleForCaption() -> some View {
		self
			.font(Font.app.title3)
			.foregroundColor(Color.white)
			.tint(Color.white)
			.multilineTextAlignment(.center)
			.padding(.vertical, 6)
			.padding(.horizontal, 40)
			.frame(maxWidth: .infinity)
			.background(Color.app.primary.opacity(0.4))
	}
}
