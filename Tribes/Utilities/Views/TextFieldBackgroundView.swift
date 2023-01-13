//
//  TextFieldBackgroundView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-08-03.
//

import SwiftUI

struct TextFieldBackgroundView: View {
	var body: some View {
		RoundedRectangle(cornerRadius: SizeConstants.cornerRadius)
			.fill(Color.app.secondary)
	}
}

struct TextFieldBackgroundView_Previews: PreviewProvider {
	static var previews: some View {
		TextFieldBackgroundView()
	}
}
