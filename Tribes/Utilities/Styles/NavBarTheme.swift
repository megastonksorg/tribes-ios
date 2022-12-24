//
//  NavBarTheme.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import UIKit

class NavBarTheme {
	static func setup(background : UIColor? = nil){
		let navigationAppearance = UINavigationBarAppearance()
		navigationAppearance.configureWithOpaqueBackground()
		navigationAppearance.backgroundColor = background ?? .black
		
		UINavigationBar.appearance().standardAppearance = navigationAppearance
		UINavigationBar.appearance().compactAppearance = navigationAppearance
	}
}
