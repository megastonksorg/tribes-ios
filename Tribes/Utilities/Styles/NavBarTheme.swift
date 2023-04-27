//
//  NavBarTheme.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import UIKit

class NavBarTheme {
	static func setup(){
		let navigationAppearance = UINavigationBarAppearance()
		navigationAppearance.configureWithOpaqueBackground()
		navigationAppearance.backgroundColor = .black
		navigationAppearance.shadowColor = .clear
		navigationAppearance.shadowImage = UIImage()
		
		UINavigationBar.appearance().standardAppearance = navigationAppearance
		UINavigationBar.appearance().compactAppearance = navigationAppearance
		UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
	}
}
