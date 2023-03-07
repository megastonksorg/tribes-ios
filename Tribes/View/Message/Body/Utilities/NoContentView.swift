//
//  NoContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct NoContentView: View {
	let isShowingErrorTip: Bool
	var body: some View {
		RoundedRectangle(cornerRadius: SizeConstants.imageCornerRadius)
			.fill(Color.black.opacity(0.4))
			.overlay(isShown: isShowingErrorTip) {
				Text("Something went wrong. Please try that again")
					.font(Font.app.body)
					.foregroundColor(Color.white)
					.dropShadow()
					.dropShadow()
			}
	}
}

struct NoContentView_Previews: PreviewProvider {
	static var previews: some View {
		NoContentView(isShowingErrorTip: false)
	}
}
