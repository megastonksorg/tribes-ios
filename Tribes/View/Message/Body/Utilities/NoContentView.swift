//
//  NoContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import SwiftUI

struct NoContentView: View {
	var body: some View {
		RoundedRectangle(cornerRadius: SizeConstants.imageCornerRadius)
			.fill(Color.black.opacity(0.4))
	}
}

struct NoContentView_Previews: PreviewProvider {
	static var previews: some View {
		NoContentView()
	}
}
