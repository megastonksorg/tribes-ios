//
//  TermsAndConditionsView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-14.
//

import SwiftUI

struct TermsAndConditionsView: View {
	struct StateButton: View {
		static let defaultOpacity: CGFloat = 0.6
		@Binding var didAcceptTerms: Bool
		
		@State var didView: Bool = false
		@State var opacity: CGFloat = defaultOpacity
		
		var viewAction: () -> ()
		
		var body: some View {
			HStack {
				Spacer()
				Button(
					action: {
						if self.didView {
							self.didAcceptTerms.toggle()
						} else {
							withAnimation(.easeOut) {
								self.opacity = 1.0
							}
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
								withAnimation(.easeIn) {
									self.opacity = TermsAndConditionsView.StateButton.defaultOpacity
								}
							}
						}
					}
				) {
					Image(systemName: didAcceptTerms ? "checkmark.square.fill" : "square")
				}
				.opacity(TermsAndConditionsView.StateButton.defaultOpacity)
				
				Button(
					action: {
						viewAction()
						if !self.didView {
							self.didView = true
						}
					}
				) {
					Text(didAcceptTerms ? "Terms Accepted" : "Read and Accept Terms To Proceed")
						.if(!didAcceptTerms) { view in
							view.underline()
						}
				}
				.opacity(opacity)
				Spacer()
			}
			.font(Font.app.subTitle)
			.foregroundColor(Color.white)
		}
	}
	
	var body: some View {
		ScrollView {
			VStack {
				Text(EULA.text)
					.font(Font.app.body)
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
			didAcceptTerms: Binding.constant(false),
			viewAction: {}
		)
		.preferredColorScheme(.dark)
		TermsAndConditionsView()
	}
}
