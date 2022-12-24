//
//  SlidingButtonView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-08-28.
//

import SwiftUI

struct SlidingButtonView: View {
	enum Style: Equatable {
		case yea
		case nay
		
		var title: String {
			switch self {
			case .yea: return "Yea"
			case .nay: return "Nay"
			}
		}
		
		var colorTheme: Color {
			switch self {
			case .yea: return Color.app.green
			case .nay: return Color.app.red
			}
		}
		
		var gradientTheme: LinearGradient {
			switch self {
			case .yea: return LinearGradient.green
			case .nay: return LinearGradient.red
			}
		}
		
		var sfSymbolName: String {
			switch self {
			case .yea: return "hand.thumbsup.fill"
			case .nay: return "hand.thumbsdown.fill"
			}
		}
	}
	
	let height: CGFloat = 60
	let buttonDiameter: CGFloat = 50
	let defaultXOffset: CGFloat = 6
	let offsetAnimation: Animation = .interactiveSpring(response: 0.4)
	
	let style: Style
	
	@State var isSliding: Bool = false
	@State var inverseProgress: CGFloat = 1.0
	@State var xOffset: CGFloat
	@State var didComplete: Bool = false
	
	init(style: Style) {
		self.style = style
		self._xOffset = State(initialValue: defaultXOffset)
	}
	
	var body: some View {
		HStack {
			GeometryReader { proxy in
				let width: CGFloat = proxy.frame(in: .local).width
				let maxXTravelDistance: CGFloat = width - (buttonDiameter + defaultXOffset / 2)
				HStack {
					ZStack(alignment: .leading) {
						if self.inverseProgress < 1 {
							Capsule()
								.fill(style.gradientTheme.opacity(1 - inverseProgress))
								.frame(width: width)
								.background(Color.black.clipShape(Capsule()))
								.offset(x: xOffset - maxXTravelDistance)
								.animation(.default, value: xOffset)
								.clipShape(Capsule())
						}
						Circle()
							.fill(style.colorTheme)
							.frame(dimension: buttonDiameter, alignment: .leading)
							.overlay(
								Image(systemName: style.sfSymbolName)
									.foregroundColor(.white)
							)
							.offset(x: xOffset)
							.animation(offsetAnimation, value: xOffset)
							.gesture(
								DragGesture()
									.onChanged { value in
										let xDistance  = value.translation.width
										
										if (defaultXOffset...maxXTravelDistance).contains(xDistance) {
											self.isSliding = true
											self.xOffset = value.translation.width
											self.inverseProgress = 1 - (xDistance / maxXTravelDistance)
											if self.inverseProgress == 0 {
												self.didComplete = true
											}
										}
									}
									.onEnded { _ in
										if !self.didComplete  {
											self.xOffset = defaultXOffset
											self.isSliding = false
											withAnimation(offsetAnimation) {
												self.inverseProgress = 1.0
											}
										}
									}
							)
					}
				}
				.frame(width: width, height: proxy.size.height, alignment: .leading)
			}
			.frame(height: self.height)
		}
		.background(
			ZStack {
				Capsule()
					.fill(Color.black)
				Text("Slide to cast your vote")
					.font(.system(.body, design: .rounded, weight: .medium))
					.foregroundStyle(LinearGradient.shine)
					.opacity(self.inverseProgress)
			}
		)
		.overlay(
			ZStack {
				Capsule()
					.stroke(self.isSliding ? style.gradientTheme : LinearGradient.gray)
				Text("You voted \(style.title)")
					.font(.system(.body, design: .rounded))
					.foregroundColor(.white)
					.opacity(self.didComplete ? 1.0 : 0.0)
			}
		)
	}
}

struct SlidingButtonView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			Spacer()
			SlidingButtonView(style: .yea)
				.padding(.horizontal, 40)
		}
	}
}
