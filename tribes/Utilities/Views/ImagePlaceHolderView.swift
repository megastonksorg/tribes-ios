//
//  ImagePlaceholderView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-13.
//

import SwiftUI

struct ImagePlaceholderView: View {
	var body: some View {
		Circle()
			.stroke(Color.white, lineWidth: 2)
			.overlay(Circle().fill(Color.black))
	}
}

struct ImagePlaceholderView_Previews: PreviewProvider {
	static var previews: some View {
		ImagePlaceholderView()
	}
}
