//
//  TextContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-11.
//

import SwiftUI

struct TextContentView: View {
	let content: String
	let isEncrypted: Bool
	let shouldRoundAllCorners: Bool
	let style: Message.Style
	
	var body: some View {
		let corners: UIRectCorner = {
			if shouldRoundAllCorners {
				return .allCorners
			} else {
				switch style {
				case .incoming: return [.topRight, .bottomLeft, .bottomRight]
				case .outgoing: return [.topLeft, .topRight, .bottomLeft]
				}
			}
		}()
		
		let color: Color = {
			switch style {
			case .incoming: return Color.app.darkRed
			case .outgoing: return Color.app.secondary
			}
		}()
		
		Text(content)
			.font(Font.app.body)
			.foregroundColor(Color.white)
			.padding(10)
			.padding(.leading, 6)
			.blur(radius: isEncrypted ? 4.0 : 0.0)
			.background(
				CustomRoundedRectangle(cornerRadius: SizeConstants.textFieldCornerRadius - 8, corners: corners)
					.fill(color)
			)
	}
}

struct TextContentView_Previews: PreviewProvider {
	static var previews: some View {
		TextContentView(
			content: "Hey there",
			isEncrypted: false,
			shouldRoundAllCorners: false,
			style: .outgoing
		)
	}
}
