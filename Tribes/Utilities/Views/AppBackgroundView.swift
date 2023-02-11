//
//  AppBackgroundView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-27.
//

import SwiftUI

struct AppBackgroundView: View {
	var body: some View {
		Color.app.background
			.overlay(
				VStack {
					Circle()
						.fill(Color.app.onBoardingBackground)
						.blur(radius: 200)
						.overlay(
							Circle()
								.fill(
									LinearGradient(
										colors: [
											Color.white,
											Color.app.onBoardingBackground
										],
										startPoint: .top,
										endPoint: .bottom
									)
								)
								.blur(radius: 120)
								.frame(height: 200)
								.offset(y: -100)
						)
					Spacer()
				}
			)
			.ignoresSafeArea()
	}
}

struct AppBackgroundView_Previews: PreviewProvider {
	static var previews: some View {
		AppBackgroundView()
	}
}
