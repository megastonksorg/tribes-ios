//
//  TermsAndConditionsView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import SwiftUI

struct TermsAndConditionsView: View {
	var body: some View {
		ScrollView {
			VStack {
				Text(EULA.text)
					.foregroundColor(.white)
					.multilineTextAlignment(.center)
					.padding(.top)
			}
			.padding()
		}
		.background(Color.app.background)
	}
}

struct TermsAndConditionsView_Previews: PreviewProvider {
	static var previews: some View {
		TermsAndConditionsView()
	}
}
