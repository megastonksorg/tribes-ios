//
//  Font+Extension.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-28.
//

import SwiftUI

extension Font {
	static func system(_ style: Font.TextStyle, design: Design = .default, weight: Weight) -> Font {
		.system(style, design: design).weight(weight)
	}
}

extension Font {
	enum app {}
}

extension Font.app {
	static var body: Font { .system(size: FontSizes.body, weight: .regular, design: .rounded) }
	static var callout: Font { .system(size: FontSizes.callout, weight: .regular, design: .rounded) }
	static var caption: Font { .system(size: FontSizes.caption, weight: .regular, design: .rounded) }
	static var footnote: Font { .system(size: FontSizes.footnote, weight: .regular, design: .rounded) }
	static var subHeader: Font { .system(size: FontSizes.title3, weight: .regular, design: .rounded) }
	static var subTitle: Font { .system(size: FontSizes.body, weight: .medium, design: .rounded) }
	static var title: Font { .system(size: FontSizes.title1, weight: .medium, design: .rounded) }
	static var title2: Font { .system(size: FontSizes.title2, weight: .medium, design: .rounded) }
	static var title3: Font { .system(size: FontSizes.title3, weight: .medium, design: .rounded) }
}
