//
//  View+Overlay.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-15.
//

import SwiftUI

extension View {
	func overlay<Content: View>(
		isShown: Bool,
		alignment: Alignment = .center,
		@ViewBuilder _ content: @escaping () -> Content
	) -> some View {
		overlay(alignment: alignment) {
			if isShown { content() }
		}
	}
}
