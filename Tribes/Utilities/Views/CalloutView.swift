//
//  CalloutView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-16.
//

import SwiftUI

struct RoundedTriangle: Shape {
	let radius: CGFloat
	
	init(radius: CGFloat) {
		self.radius = radius
	}

	func path(in rect: CGRect) -> Path {
		let width = rect.width
		let height = rect.height
		
		let point1 = CGPoint(x: 0, y: 0)
		let point2 = CGPoint(x: width, y: height/2)
		let point3 = CGPoint(x: 0, y: height)
		
		var path = Path()
		path.move(to: CGPoint(x: 0, y: height/2))
		path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
		path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
		path.addArc(tangent1End: point3, tangent2End: point1, radius: radius)
		path.closeSubpath()
		return path
	}
}

struct CalloutView: View {
	let size: CGSize
	let fill: Color
	var body: some View {
		VStack(spacing: 0) {
			Capsule()
				.fill(fill)
				.frame(width: size.width, height: size.height)
			RoundedTriangle(radius: 4)
				.fill(fill)
				.frame(dimension: 26)
				.rotationEffect(.degrees(90))
				.offset(y: -6)
		}
	}
}

struct CalloutView_Previews: PreviewProvider {
	static var previews: some View {
		CalloutView(size: CGSize(width: 200, height: 60), fill: Color.app.secondary)
	}
}
