//
//  XButton.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import SwiftUI

struct XButton: View {
	let action: () -> ()
	var body: some View {
		Button(action: { action() }) {
			Image(systemName: "x.circle.fill")
				.font(Font.app.title)
				.foregroundColor(Color.white)
		}
	}
}

struct XButton_Previews: PreviewProvider {
	static var previews: some View {
		XButton {
			()
		}
		.preferredColorScheme(.dark)
	}
}
