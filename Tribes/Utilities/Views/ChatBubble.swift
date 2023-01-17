//
//  ChatBubble.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-16.
//

import SwiftUI

struct ChatBubble: View {
	let cornerRadius: CGFloat = 30
	
	let content: String
	let type: ChatType
	
	var body: some View {
		let corners: UIRectCorner = {
			switch type {
			case .incoming: return [.topRight, .bottomLeft, .bottomRight]
			case .outgoing: return [.topLeft, .topRight, .bottomLeft]
			}
		}()
		
		let color: Color = {
			switch type {
			case .incoming: return Color.app.secondary
			case .outgoing: return Color.app.tertiary
			}
		}()
		
		let foregroundColor: Color = {
			switch type {
			case .incoming: return Color.white
			case .outgoing: return Color.black
			}
		}()
		
		Text(content)
			.font(Font.app.subTitle)
			.foregroundColor(foregroundColor)
			.padding()
			.background(
				CustomRoundedRectangle(cornerRadius: cornerRadius, corners: corners)
					.fill(color)
			)
	}
}

struct ChatBubble_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			ChatBubble(content: "Stop there. Please change account info when you get a chance", type: .incoming)
		}
		.pushOutFrame()
		.background(Color.app.background)
	}
}
