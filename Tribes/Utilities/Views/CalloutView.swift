//
//  CalloutView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-16.
//

import SwiftUI

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
				.offset(y: -8)
		}
	}
}

struct CalloutView_Previews: PreviewProvider {
	static var previews: some View {
		CalloutView(size: CGSize(width: 200, height: 60), fill: Color.app.secondary)
	}
}
