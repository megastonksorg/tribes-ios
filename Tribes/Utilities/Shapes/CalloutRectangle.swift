//
//  CalloutRectangle.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import SwiftUI

struct CalloutRectangle: Shape {
	var calloutRadius: CGFloat = 10
	var radius: CGFloat = .zero
	var corners: UIRectCorner = .allCorners
	
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		let p1 = CGPoint(x: rect.minX, y: corners.contains(.topLeft) ? rect.minY + radius  : rect.minY )
		let p2 = CGPoint(x: corners.contains(.topLeft) ? rect.minX + radius : rect.minX, y: rect.minY )
		
		let p3 = CGPoint(x: corners.contains(.topRight) ? rect.maxX - radius : rect.maxX, y: rect.minY )
		let p4 = CGPoint(x: rect.maxX, y: corners.contains(.topRight) ? rect.minY + radius  : rect.minY )
		
		let p5 = CGPoint(x: rect.maxX, y: corners.contains(.bottomRight) ? rect.maxY - radius : rect.maxY )
		let p6 = CGPoint(x: corners.contains(.bottomRight) ? rect.maxX - radius : rect.maxX, y: rect.maxY )
		
		let p7 = CGPoint(x: rect.maxX * 0.90, y: rect.maxY)
		let p8 = CGPoint(x: rect.maxX * 0.86, y: rect.maxY + 20)
		
		let p9 = CGPoint(x: rect.maxX * 0.82, y: rect.maxY)
		
		let p10 = CGPoint(x: corners.contains(.bottomLeft) ? rect.minX + radius : rect.minX, y: rect.maxY )
		let p11 = CGPoint(x: rect.minX, y: corners.contains(.bottomLeft) ? rect.maxY - radius : rect.maxY )
		
		path.move(to: p1)
		path.addArc(
			tangent1End: CGPoint(x: rect.minX, y: rect.minY),
			tangent2End: p2,
			radius: radius
		)
		
		path.addLine(to: p3)
		path.addArc(
			tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
			tangent2End: p4,
			radius: radius
		)
		
		path.addLine(to: p5)
		path.addArc(
			tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
			tangent2End: p6,
			radius: radius
		)
		
		path.addLine(to: p7)
		path.addArc(
			tangent1End: p8,
			tangent2End: p9,
			radius: calloutRadius
		)
		
		path.addLine(to: p9)
		path.addLine(to: p10)
		path.addArc(
			tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
			tangent2End: p11,
			radius: radius
		)
		
		path.closeSubpath()
		
		return path
	}
}

struct CalloutRectangle_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			CalloutRectangle(calloutRadius: 8, radius: 20)
				.frame(height: 300)
				.padding(.horizontal)
		}
	}
}
