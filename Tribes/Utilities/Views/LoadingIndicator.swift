//
//  LoadingIndicator.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-31.
//

import SwiftUI

struct LoadingIndicator: View {
	enum Style {
		case base
		case media
	}
	
	var speed: CGFloat = 0.6
	var style: Style = .base
	
	@State var isAnimating: Bool = false
	
	var body: some View {
		let defaultColor: Color = {
			switch style {
			case .base:
				return Color.app.tertiary
			case .media:
				return Color.white
			}
		}()
		Circle()
			.trim(from: 0, to: 0.4)
			.stroke(style: StrokeStyle(lineWidth: 5.00, lineCap: .round, lineJoin: .round))
			.fill(LinearGradient(colors: [defaultColor, .gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
			.rotationEffect(isAnimating ? .degrees(360): .degrees(0))
			.animation(.linear.speed(speed).repeatForever(autoreverses: false), value: self.isAnimating)
			.onAppear {
				self.isAnimating = true
			}
	}
}

struct LoadingIndicator_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			LoadingIndicator()
				.frame(dimension: 40)
			LoadingIndicator(style: .media)
				.frame(dimension: 40)
		}
		.pushOutFrame()
		.background(Color.black)
	}
}
