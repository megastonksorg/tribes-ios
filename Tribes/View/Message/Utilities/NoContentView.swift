//
//  NoContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct NoContentView: View {
	let isEncrypted: Bool
	let reloadContent: () -> ()
	var body: some View {
		RoundedRectangle(cornerRadius: SizeConstants.imageCornerRadius)
			.fill(Color.black.opacity(0.4))
			.ignoresSafeArea()
			.overlay {
				VStack {
					Group {
						if isEncrypted {
							Button(action: { reloadContent() }) {
								Image(systemName: AppConstants.encryptedIcon)
									.symbolRenderingMode(.palette)
									.foregroundStyle(Color.app.secondary, Color.white)
									.font(.system(size: 40))
							}
						} else {
							VStack {
								Text("Could not load content")
									.font(Font.app.body)
									.foregroundColor(Color.white)
								Button(action: { reloadContent() }) {
									Image(systemName: "arrow.counterclockwise.circle.fill")
										.font(Font.app.title)
										.foregroundColor(Color.white)
										.padding()
								}
							}
						}
					}
				}
				.dropShadow()
				.dropShadow()
			}
	}
}

struct NoContentView_Previews: PreviewProvider {
	static var previews: some View {
		NoContentView(isEncrypted: true, reloadContent: {})
		NoContentView(isEncrypted: false, reloadContent: {})
	}
}
