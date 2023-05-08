//
//  CalloutView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-16.
//

import SwiftUI

struct CalloutView: View {
	enum Style {
		case regular
		case alternate
	}
	
	let content: String
	let fill: Color
	let fontSize: CGFloat
	
	@State var height: CGFloat = .zero
	
	init(content: String, style: Style = .regular, fontSize: CGFloat = FontSizes.body) {
		self.content = content
		self.fill = {
			switch style {
			case .regular: return Color.app.secondary
			case .alternate: return Color.app.divider
			}
		}()
		self.fontSize = fontSize
	}
	
	var body: some View {
		Text(content)
			.font(.system(size: fontSize, weight: .regular, design: .rounded))
			.foregroundColor(Color.white)
			.multilineTextAlignment(.center)
			.lineLimit(2)
			.padding(.horizontal)
			.padding(.vertical, 8)
			.background(
				ZStack {
					Capsule()
						.fill(fill)
					RoundedTriangle(radius: 4)
						.fill(fill)
						.frame(dimension: 26)
						.rotationEffect(.degrees(90))
						.offset(y: self.height * 0.6)
				}
				.compositingGroup()
			)
			.readSize { self.height = $0.height }
	}
}

struct CalloutView_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 40) {
			CalloutView(content: "What is my name? Could you tell me")
			Button(action: {}) {
				CalloutView(content: "😂", style: .alternate)
			}
		}
	}
}
