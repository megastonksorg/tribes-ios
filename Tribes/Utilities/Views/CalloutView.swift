//
//  CalloutView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-16.
//

import SwiftUI

struct CalloutView: View {
	let content: String
	let fill: Color = Color.app.secondary
	var fontSize: CGFloat = FontSizes.body
	
	@State var height: CGFloat = .zero
	
	var body: some View {
		Text(content)
			.font(.system(size: fontSize, weight: .regular, design: .rounded))
			.foregroundColor(Color.white)
			.multilineTextAlignment(.center)
			.lineLimit(2)
			.padding(10)
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
				CalloutView(content: "😂")
			}
		}
	}
}
