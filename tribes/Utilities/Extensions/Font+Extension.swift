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
	static var title: Font { .system(.title3, design: .rounded, weight: .medium) }
	static var subTitle: Font { .system(size: 15, weight: .medium, design: .rounded) }
	static var footer: Font { .system(size: 12, weight: .regular, design: .rounded) }
}
