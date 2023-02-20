//
//  ExpandedButtonStyle.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-05-31.
//

import SwiftUI

struct ExpandedButtonStyle: ButtonStyle {
	
	let shouldAnimate: Bool
	let invertedStyle: Bool
	
	@Environment(\.isEnabled) private var isEnabled
	
	init (shouldAnimate: Bool = true, invertedStyle: Bool = false) {
		self.shouldAnimate = shouldAnimate
		self.invertedStyle = invertedStyle
	}
	
	func makeBody(configuration: Configuration) -> some View {
		let foregroundColor: Color = {
			if self.isEnabled {
				return self.invertedStyle ? Color.app.tertiary : Color.white
			} else {
				return .gray
			}
		}()
		
		HStack {
			Spacer()
			configuration.label
				.font(Font.app.title3)
				.textCase(.uppercase)
				.foregroundColor(foregroundColor)
				.padding()
			Spacer()
		}
		.background {
			if invertedStyle {
				invertedButtonStyleView()
			} else {
				if isEnabled {
					shape()
						.fill(Color.app.secondary)
				} else {
					invertedButtonStyleView()
				}
			}
		}
		.padding(.horizontal)
		.scaleEffect(shouldAnimate && configuration.isPressed ? 0.95 : 1)
		.animation(.easeInOut.speed(2.0), value: shouldAnimate && configuration.isPressed)
	}
	
	private func shape() -> some Shape {
		RoundedRectangle(cornerRadius: SizeConstants.cornerRadius)
	}
	
	private func invertedButtonStyleView() -> some View {
		shape()
			.fill(.black)
			.overlay(
				shape()
					.stroke(lineWidth: 1)
					.fill(isEnabled ? Color.app.tertiary : Color.gray)
			)
	}
}

extension ButtonStyle where Self == ExpandedButtonStyle {
	static var expanded: Self { ExpandedButtonStyle() }
	static func expanded(shouldAnimate: Bool = true, invertedStyle: Bool) -> Self {
		return ExpandedButtonStyle(shouldAnimate: shouldAnimate, invertedStyle: invertedStyle)
	}
}

struct ScalingButtonStyle: ButtonStyle {
	enum ScaleDirection {
		case inside
		case outside
	}
	
	let direction: ScaleDirection
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? direction == .inside ? 0.96 : 1.04 : 1)
			.animation(.easeInOut.speed(2.0), value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == ScalingButtonStyle {
	static var insideScaling: Self { ScalingButtonStyle(direction: .inside) }
	static var outsideScaling: Self { ScalingButtonStyle(direction: .outside) }
}
