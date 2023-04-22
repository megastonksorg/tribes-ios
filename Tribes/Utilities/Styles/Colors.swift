//
//  Colors.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-05-15.
//

import SwiftUI

extension Color {
	enum app {}
}

extension Color.app {
	//Main
	static let primary: Color = Color(uiColor: UIColor(hex: "450E00"))
	static let secondary: Color = Color(uiColor: UIColor(hex: "941E00"))
	static let tertiary: Color = Color(uiColor: UIColor(hex: "B79489"))
	
	//Others
	static let background: Color = Color.black
	static let backGroundOnboarding: Color = Color(uiColor: UIColor(hex: "941E00"))
	static let bannerStroke: Color = Color(uiColor: UIColor(hex: "7B2111"))
	static let black: Color = Color(uiColor: UIColor(hex: "0D1114"))
	static let camera: Color = Color(uiColor: UIColor(hex: "F1C5BA"))
	static let cardStroke: Color = Color.white.opacity(0.1)
	static let divider: Color = Color(uiColor: UIColor(hex: "1C1A1B"))
	static let red: Color = Color(uiColor: UIColor(hex: "D73A3A"))
	static let darkRed: Color = Color(uiColor: UIColor(hex: "310000"))
	static let textFieldCursor: Color = Color.white
}
