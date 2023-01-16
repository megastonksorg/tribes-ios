//
//  RoundedTriangle.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-16.
//

import Foundation
import SwiftUI

struct RoundedTriangle: Shape {
	let radius: CGFloat

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
