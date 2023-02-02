//
//  TextView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-12.
//

import SwiftUI

struct TextViewModifier: ViewModifier {
	enum Style {
		case appTitle
		case bodyTitle
		case callout
		case error
		case hint
		case pageTitle
		case pageSubTitle
		case tribeName(_ size: CGFloat)
	}
	
	let style: Style
	
	func body(content: Content) -> some View {
		switch style {
		case .appTitle:
			content
				.font(.custom(FontNames.kreon, fixedSize: 40))
				.foregroundColor(Color.app.tertiary)
		case .bodyTitle:
			content
				.font(Font.app.subTitle)
				.foregroundColor(Color.app.tertiary)
		case .callout:
			content
				.font(Font.app.callout)
				.foregroundColor(.gray)
		case .error:
			content
				.font(Font.app.subHeader)
				.foregroundColor(Color.app.red)
		case .hint:
			content
				.font(Font.app.caption)
				.foregroundColor(.gray)
		case .pageTitle:
			content
				.font(Font.app.title3)
				.foregroundColor(Color.app.tertiary)
		case .pageSubTitle:
			content
				.font(Font.app.subHeader)
				.foregroundColor(Color.app.tertiary)
		case .tribeName(let size):
			content
				.font(.system(size: size, weight: .medium, design: .rounded))
				.foregroundColor(Color.app.tertiary)
				.multilineTextAlignment(.center)
				.lineLimit(2)
		}
	}
}

fileprivate extension View {
	func styleText(style: TextViewModifier.Style) -> some View {
		modifier(TextViewModifier(style: style))
	}
}

struct TextView: View {
	let content: String
	let style: TextViewModifier.Style
	
	init(_ content: String, style: TextViewModifier.Style) {
		self.content = content
		self.style = style
	}
	
	var body: some View {
		Text(content)
			.styleText(style: style)
	}
}

struct TextView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			TextView("Tribes", style: .appTitle)
			TextView("Belly Squad", style: .tribeName(20))
		}
	}
}
