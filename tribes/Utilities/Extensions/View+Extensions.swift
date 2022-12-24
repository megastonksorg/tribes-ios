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
}
