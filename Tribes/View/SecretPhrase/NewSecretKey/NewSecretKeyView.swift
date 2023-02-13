//
//  NewSecretKeyView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-28.
//

import SwiftUI
import IdentifiedCollections

struct NewSecretKeyView: View {
	
	@StateObject var viewModel: ViewModel = ViewModel()
	
	@EnvironmentObject var appRouter: AppRouter
	
	var body: some View {
		VStack(spacing: 20) {
			if viewModel.phrase.isEmpty {
				Text("Could not generate a secret key for you.\nPlease try that again")
					.font(Font.app.title2)
					.foregroundColor(.white)
					.pushOutFrame()
			}
			else {
				Text("Secret account key")
					.font(Font.app.title)
					.foregroundColor(.white)
				
				Text("This key is the only way you will be able to login to your account. Please memorize or write it down somewhere safe. \n\nIt protects your money and conversations")
					.font(Font.app.body)
					.foregroundColor(.gray)
					.padding(.horizontal)
					.padding(.top)
					.fixedSize(horizontal: false, vertical: true)
				
				LazyVGrid(columns: Array(repeating: GridItem(), count: SizeConstants.phraseGridCount), spacing: SizeConstants.phraseGridSpacing) {
					ForEach(viewModel.phrase){ word in
						MnemonicWordView(word: $viewModel.phrase[id: word.id])
							.padding(.vertical)
					}
				}
				.padding(.horizontal, 4)
				
				Spacer(minLength: 0)
				
				Text("DO NOT SHARE THIS WITH ANYONE!!")
					.font(Font.app.subTitle)
					.foregroundColor(.gray)
					.multilineTextAlignment(.center)
				
				Spacer(minLength: 0)
				
				Button(action: { viewModel.verifyMnemonicPhrase() }) {
					Text("I saved it somewhere safe")
						.fontWeight(.medium)
				}
				.buttonStyle(ExpandedButtonStyle(invertedStyle: false))
			}
		}
		.padding()
		.multilineTextAlignment(.center)
		.background(Color.app.background)
	}
}

struct NewSecretKeyView_Previews: PreviewProvider {
	static var previews: some View {
		NewSecretKeyView()
	}
}
