//
//  NoteBackgroundView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-29.
//

import SwiftUI

struct NoteBackgroundView: View {
	enum Style {
		case orange
		case purple
	}
	
	let style: Style
	
	@State private var size: CGSize = .zero
	
	var body: some View {
		let colors: [Color] = {
			switch style {
			case .orange:
				return [
					Color(uiColor: UIColor(hex: "CE8D52")),
					Color(uiColor: UIColor(hex: "CE5252"))
				]
			case .purple:
				return [
					Color(uiColor: UIColor(hex: "52CEA9")),
					Color(uiColor: UIColor(hex: "7252CE"))
				]
			}
		}()
		RadialGradient(
			colors: colors,
			center: .center,
			startRadius: size.height * 0.10,
			endRadius: size.height * 0.50
		)
		.readSize { self.size = $0 }
	}
}

struct NoteBackgroundView_Previews: PreviewProvider {
	static var previews: some View {
		NoteBackgroundView(style: .purple)
	}
}
