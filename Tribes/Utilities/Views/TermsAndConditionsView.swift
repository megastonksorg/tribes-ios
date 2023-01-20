//
//  TermsAndConditionsView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import SwiftUI

struct TermsAndConditionsView: View {
	struct StateButton: View {
		@Binding var didAcceptTerms: Bool
		
		@State var didView: Bool = false
		
		var viewAction: () -> ()
		
		var body: some View {
			HStack {
				Spacer()
				Button(
					action: {
						if self.didView {
							self.didAcceptTerms.toggle()
						}
					}
				) {
					Image(systemName: didAcceptTerms ? "checkmark.square.fill" : "square")
				}
				Button(
					action: {
						viewAction()
						if !self.didView {
							self.didView = true
						}
					}
				) {
					Text(didAcceptTerms ? "Terms Accepted" : "Read and Accept Terms To Proceed")
				}
				Spacer()
			}
			.font(Font.app.subTitle)
			.foregroundColor(didAcceptTerms ? Color.app.tertiary : Color.white)
			.opacity(0.6)
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
		TermsAndConditionsView.StateButton(
			didAcceptTerms: Binding.constant(true),
			viewAction: {}
		)
		TermsAndConditionsView()
	}
}
