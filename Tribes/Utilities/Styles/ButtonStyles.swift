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
			if self.invertedStyle { return .gray }
			if self.isEnabled {
				return .black
			} else {
				return .gray
			}
		}()
		
		HStack {
			Spacer()
			configuration.label
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
		.scaleEffect(shouldAnimate && configuration.isPressed ? 1.05 : 1)
		.animation(.easeOut(duration: 0.6), value: shouldAnimate && configuration.isPressed)
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
					.fill(Color.gray)
			)
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
			.scaleEffect(configuration.isPressed ? direction == .inside ? 0.95 : 1.05 : 1)
			.animation(.default, value: configuration.isPressed)
	}
}

extension ButtonStyle where Self == ScalingButtonStyle {
	static var insideScaling: Self { ScalingButtonStyle(direction: .inside) }
	static var outsideScaling: Self { ScalingButtonStyle(direction: .outside) }
}
