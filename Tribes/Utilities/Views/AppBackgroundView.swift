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
						.fill(Color.app.backGroundOnboarding)
						.blur(radius: 120)
						.offset(y: -60)
						.overlay(
							Circle()
								.fill(
									LinearGradient(
										colors: [
											Color.white,
											Color.app.backGroundOnboarding
										],
										startPoint: .top,
										endPoint: .bottom
									)
								)
								.blur(radius: 120)
								.frame(height: 120)
								.offset(y: -50)
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
