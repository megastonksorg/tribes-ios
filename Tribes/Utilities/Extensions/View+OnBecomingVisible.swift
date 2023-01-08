//
//  View+OnBecomingVisible.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-08.
//

import SwiftUI

extension View {
	
	func onBecomingVisible(xMinimum: Double = 0.3, perform action: @escaping () -> Void) -> some View {
		// xMinimum here is what factor of the view's width relative to the screen width we want to determine visibility
		modifier(BecomingVisible(xMinimum: xMinimum, action: action))
	}
}

private struct BecomingVisible: ViewModifier {
	let xMinimum: Double
	
	var action: () -> Void

	func body(content: Content) -> some View {
		content.background {
			GeometryReader { proxy in
				Color.clear
					.preference(
						key: VisibleKey.self,
						value: proxy.frame(in: .global).maxX > UIScreen.main.bounds.maxX * xMinimum
					)
					.onPreferenceChange(VisibleKey.self) { isVisible in
						guard isVisible else { return }
						action()
					}
			}
		}
	}

	struct VisibleKey: PreferenceKey {
		static var defaultValue: Bool = false
		static func reduce(value: inout Bool, nextValue: () -> Bool) { }
	}
}
