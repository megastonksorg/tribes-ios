//
//  CardView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import SwiftUI

struct CardView<Content: View>: View {
	@Binding var isShowing: Bool
	let dismissAction: () -> ()
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
				.padding(.bottom)
				.padding(.bottom)
				.transition(AnyTransition.move(edge: .bottom))
			}
		}
		.pushOutFrame()
		.background(
			Color.app.background.opacity(0.8)
				.onTapGesture {
					withAnimation(Animation.cardView) {
						self.isShowing = false
						dismissAction()
					}
				}
		)
		.ignoresSafeArea()
		.readSize(onChange: { self.size =  $0 })
	}
}

extension View {
	func cardView<Content: View>(
		isShowing: Binding<Bool>,
		dismissAction: @escaping () -> Void,
		content: @escaping () -> Content
	) -> some View {
		self.overlay(isShown: isShowing.wrappedValue) {
			CardView(isShowing: isShowing, dismissAction: dismissAction) {
				content()
			}
		}
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
			Button(action: { withAnimation(Animation.cardView) { isShowing = true } }) {
				Text("Press Me")
					.padding()
			}
		}
		.pushOutFrame()
		.background(Color.black)
		.overlay(isShown: isShowing) {
			CardView(isShowing: $isShowing, dismissAction: {}) { Text("Testing Here") }
		}
	}
}
