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
		case camera
		case tribeAvatar
	}
	
	var speed: CGFloat = 0.6
	var style: Style = .base
	var lineWidth: CGFloat = 5.00
	var trim: CGFloat = 0.4
	
	@State var isAnimating: Bool = false
	
	var body: some View {
		let colors: [Color] = {
			switch style {
			case .base:
				return [Color.app.tertiary, Color.gray.opacity(0.4)]
			case .camera:
				return [Color.white, Color.gray.opacity(0.4)]
			case .tribeAvatar:
				return [Color.red, Color.app.secondary]
			}
		}()
		Circle()
			.trim(from: 0, to: trim)
			.stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
			.fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
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
			LoadingIndicator(style: .camera)
				.frame(dimension: 40)
		}
		.pushOutFrame()
		.background(Color.black)
	}
}
