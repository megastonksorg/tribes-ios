//
//  VerifySecretPhraseView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-29.
//

import SwiftUI
import IdentifiedCollections

struct VerifySecretPhraseView: View {
	
	@StateObject var viewModel: ViewModel = ViewModel()
	
	@EnvironmentObject var appRouter: AppRouter
	
	var body: some View {
		VStack(spacing: 10) {
			Text("Verify your secret key to continue")
				.font(Font.app.subTitle)
				.foregroundColor(.white)
			
			Text("Tap an empty box to select it and fill it with one of the words below.")
				.font(Font.app.footnote)
				.foregroundColor(.white)
			
			LazyVGrid(columns: Array(repeating: GridItem(), count: SizeConstants.phraseGridCount), spacing: SizeConstants.phraseGridSpacing) {
				ForEach(viewModel.phraseInput) { input in
					MnemonicWordView(
						word: self.$viewModel.phraseInput[id: input.id],
						viewHandler: { self.viewModel.phraseInputSelected(input: input) }
					)
					.padding(.vertical, 10)
				}
			}
			
			Rectangle()
				.fill(Color.gray.opacity(0.4))
				.frame(height: 2)
			
			LazyVGrid(columns: Array(repeating: GridItem(), count: SizeConstants.phraseGridCount), spacing: SizeConstants.phraseGridSpacing) {
				ForEach(viewModel.phraseOptions) { word in
					MnemonicWordView(
						word: self.$viewModel.phraseOptions[id: word.id],
						viewHandler: { self.viewModel.phraseOptionSelected(option: word) }
					)
					.padding(.vertical, 10)
				}
			}
			.padding(.bottom)
			
			Spacer()
			
			Button(action: { self.viewModel.verifyMnemonicPhrase() }) {
				Text("Continue")
					.fontWeight(.medium)
			}
			.buttonStyle(.expanded(invertedStyle: false))
			.disabled(!self.viewModel.isContinueButtonDisabled)
		}
		.padding()
		.multilineTextAlignment(.center)
		.background(Color.app.background)
		.overlay(isShown: viewModel.isLoading) {
			AppProgressView()
		}
		.banner(data: $viewModel.banner)
	}
}

struct VerifySecretPhraseView_Previews: PreviewProvider {
	static var viewModel: VerifySecretPhraseView.ViewModel {
		let viewModel = VerifySecretPhraseView.ViewModel()
		viewModel.phraseInput = MnemonicPhrase.empty
		viewModel.phraseOptions = MnemonicPhrase.previewAlternateStyle
		return viewModel
	}
	
	static var previews: some View {
		VerifySecretPhraseView(viewModel: viewModel)
	}
}
