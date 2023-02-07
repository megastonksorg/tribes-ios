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
	static let primary: Color = Color(uiColor: UIColor(hex: "1F0602"))
	static let secondary: Color = Color(uiColor: UIColor(hex: "561C10"))
	static let tertiary: Color = Color(uiColor: UIColor(hex: "B79489"))
	
	//Others
	static let background: Color = Color.black
	static let black: Color = Color(uiColor: UIColor(hex: "0D1114"))
	static let card: Color = Color(uiColor: UIColor(hex: "232328"))
	static let cardStroke: Color = Color(uiColor: UIColor(hex: "3E3E3E"))
	static let divider: Color = Color(uiColor: UIColor(hex: "1C1A1B"))
	static let red: Color = Color(uiColor: UIColor(hex: "D73A3A"))
	static let textFieldCursor: Color = Color.white
}
