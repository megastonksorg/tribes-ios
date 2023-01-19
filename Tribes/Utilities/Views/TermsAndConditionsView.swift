//
//  TermsAndConditionsView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import SwiftUI

struct TermsAndConditionsView: View {
	struct StateButton: View {
		var didAcceptTerms: Bool
		var action: () -> ()
		var body: some View {
			Button(action: { action() } ) {
				HStack {
					Spacer()
					Image(systemName: didAcceptTerms ? "checkmark.square.fill" : "square")
					Text(didAcceptTerms ? "Terms Accepted" : "Accept Terms To Proceed")
					Spacer()
				}
				.font(Font.app.subTitle)
				.foregroundColor(.white)
				.opacity(0.6)
			}
		}
	}
	
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
