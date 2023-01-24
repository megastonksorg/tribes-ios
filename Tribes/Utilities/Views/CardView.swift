//
//  CardView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import SwiftUI

struct CardView<Content: View>: View {
	@Binding var isShowing: Bool
	let content: () -> Content
	@State var size: CGSize = .zero
	
	var body: some View {
		VStack {
			Spacer()
			if isShowing {
				ZStack {
					let cornerRadius: CGFloat = 30
					RoundedRectangle(cornerRadius: cornerRadius)
						.fill(Color.app.background)
					RoundedRectangle(cornerRadius: cornerRadius)
						.stroke(Color.app.tertiary, lineWidth: 1)
					content()
				}
				.frame(dimension: size.width * 0.9)
				.transition(AnyTransition.move(edge: .bottom))
				.padding(.bottom)
			}
		}
		.pushOutFrame()
		.background(
			Color.app.background.opacity(0.2)
				.onTapGesture {
					withAnimation(Animation.cardView) {
						self.isShowing.toggle()
					}
				}
		)
		.ignoresSafeArea()
		.readSize(onChange: { self.size =  $0 })
	}
}

struct CardView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			TestView()
		}
	}
}

fileprivate struct TestView: View {
	@State var isShowing: Bool = false
	var body: some View {
		VStack {
			Button(action: { withAnimation(Animation.cardView) { isShowing.toggle() } }) {
				Text("Press Me")
			}
		}
		.pushOutFrame()
		.background(Color.black)
		.overlay(isShown: isShowing) {
			CardView(isShowing: $isShowing) { Text("Testing Here") }
		}
	}
}
