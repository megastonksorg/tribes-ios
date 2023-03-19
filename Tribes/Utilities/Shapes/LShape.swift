//
//  LShape.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-18.
//

import SwiftUI

struct LShape: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: CGPoint(x: rect.minX, y: rect.minY))
		path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.8))
		path.addCurve(to: CGPoint(x: rect.maxX * 0.2, y: rect.maxY), control1: CGPoint(x: rect.minX, y: rect.maxY * 0.9), control2: CGPoint(x: rect.minX, y: rect.maxY))
		path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
		return path
	}
}

struct LShape_Previews: PreviewProvider {
	static var previews: some View {
		LShape()
			.stroke(lineWidth: 4)
			.frame(width: 30, height: 60)
	}
}
