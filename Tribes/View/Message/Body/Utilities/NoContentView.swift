//
//  NoContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct NoContentView: View {
	let isEncrypted: Bool
	var body: some View {
		RoundedRectangle(cornerRadius: SizeConstants.imageCornerRadius)
			.fill(Color.black.opacity(0.4))
			.overlay(isShown: isEncrypted) {
				Image(systemName: AppConstants.encryptedIcon)
					.symbolRenderingMode(.palette)
					.foregroundStyle(Color.app.secondary, Color.white)
					.font(.system(size: 40))
					.dropShadow()
					.dropShadow()
			}
			.overlay(isShown: !isEncrypted) {
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
		NoContentView(isEncrypted: true)
		NoContentView(isEncrypted: false)
	}
}
