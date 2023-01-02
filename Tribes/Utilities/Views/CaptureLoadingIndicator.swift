//
//  CaptureLoadingIndicator.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-31.
//

import SwiftUI

struct CaptureLoadingIndicator: View {
	@State var isAnimating: Bool = false
	
	var body: some View {
		Circle()
			.trim(from: 0, to: 0.4)
			.stroke(style: StrokeStyle(lineWidth: 5.00, lineCap: .round, lineJoin: .round))
			.fill(LinearGradient(colors: [.white, .gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
			.rotationEffect(isAnimating ? .degrees(360): .degrees(0))
			.animation(.linear.speed(0.6).repeatForever(autoreverses: false), value: self.isAnimating)
			.onAppear {
				self.isAnimating = true
			}
	}
}

struct CaptureLoadingIndicator_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			CaptureLoadingIndicator()
				.frame(dimension: 40)
		}
		.pushOutFrame()
		.background(Color.black)
	}
}
