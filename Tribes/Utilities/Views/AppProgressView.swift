//
//  AppProgressView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-15.
//

import SwiftUI

struct AppProgressView: View {
	var body: some View {
		Color.black.opacity(0.2).ignoresSafeArea()
			.overlay(
				LoadingIndicator(speed: 0.4)
					.frame(dimension: SizeConstants.loadingIndicatorSize)
			)
	}
}

struct AppProgressView_Previews: PreviewProvider {
	static var previews: some View {
		AppProgressView()
	}
}
