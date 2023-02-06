//
//  AppContextMenu.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-05.
//

import SwiftUI


struct BoundsPreference: PreferenceKey {
	static var defaultValue: [String: Anchor<CGRect>] = [:]
	
	static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
		value.merge(nextValue()){$1}
	}
}

struct AppContextMenu: View {
	var body: some View {
		Text("Hello, World!")
	}
}

struct AppContextMenu_Previews: PreviewProvider {
	static var previews: some View {
		AppContextMenu()
	}
}
