//
//  Colors.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-05-15.
//

import SwiftUI

public extension Color {
	enum app {}
}

public extension Color.app {
	static let background: Color = Color.black
	static let black: Color = Color(uiColor: UIColor(hex: "0D1114"))
	static let green: Color = Color(uiColor: UIColor(hex: "3AD77E"))
	static let darkGreen: Color = Color(uiColor: UIColor(hex: "4BBD20"))
	static let red: Color = Color(uiColor: UIColor(hex: "D73A3A"))
	static let card: Color = Color(uiColor: UIColor(hex: "232328"))
	static let cardStroke: Color = Color(uiColor: UIColor(hex: "3E3E3E"))
}
