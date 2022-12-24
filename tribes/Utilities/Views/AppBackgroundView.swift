//
//  AppBackgroundView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-27.
//

import SwiftUI

struct AppBackgroundView: View {
	var body: some View {
		LinearGradient.background
			.overlay(LinearGradient.black)
			.overlay(
				Circle()
					.fill(Color.app.green)
					.frame(size: SizeConstants.backgroundCircle)
					.blur(radius: 80)
			)
			.ignoresSafeArea()
	}
}

struct AppBackgroundView_Previews: PreviewProvider {
	static var previews: some View {
		AppBackgroundView()
	}
}
