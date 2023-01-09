//
//  ImportSecretPhraseView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-10.
//

import SwiftUI

struct ImportSecretPhraseView: View {
	@FocusState private var focusedField: ViewModel.Field?
	
	@StateObject var viewModel: ViewModel = ViewModel()
	
	@EnvironmentObject var appRouter: AppRouter
		
	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				Text("Type in your wallet phrase into each box to import it. You must type the phrase in the correct order for valid authentication")
					.font(.app.subTitle)
					.foregroundColor(.white)
					.multilineTextAlignment(.center)
					.padding(.bottom, 30)
				
				LazyVGrid(columns: Array(repeating: GridItem(), count: SizeConstants.phraseGridCount), spacing: SizeConstants.phraseGridSpacing) {
					ForEach(ViewModel.Field.allCases) { field in
						let word: Binding<String> = {
							switch field {
								case .one: return $viewModel.word1
								case .two: return $viewModel.word2
								case .three: return $viewModel.word3
								case .four: return $viewModel.word4
								case .five: return $viewModel.word5
								case .six: return $viewModel.word6
								case .seven: return $viewModel.word7
								case .eight: return $viewModel.word8
								case .nine: return $viewModel.word9
								case .ten: return $viewModel.word10
								case .eleven: return $viewModel.word11
								case .twelve: return $viewModel.word12
							}
						}()
						
						let isFocusedField: Bool = {
							return field == focusedField
						}()
						
						let cornerRadius: CGFloat = SizeConstants.wordCornerRadius
						let frame: CGSize = SizeConstants.wordSize
						let isWordReal: Bool = word.wrappedValue.isRealWord
						
						TextField(
							"",
							text: word,
							onCommit: { self.viewModel.advanceToNextField() }
						)
						.foregroundColor(isWordReal ? .black : .white)
						.font(.system(.subheadline, weight: .bold))
						.multilineTextAlignment(.center)
						.minimumScaleFactor(0.6)
						.lineLimit(1)
						.focused($focusedField, equals: field)
						.padding(.horizontal, 4)
						.background {
							if isWordReal {
								RoundedRectangle(cornerRadius: cornerRadius)
									.fill(Color.app.secondary)
									.frame(size: frame)
							}
							else {
								RoundedRectangle(cornerRadius: cornerRadius)
									.stroke(Color.gray.opacity(isFocusedField ? 1.0 : 0.5), lineWidth: 2)
									.frame(size: frame)
							}
						}
						.frame(size: frame)
						.padding(.vertical)
						.animation(.easeInOut, value: word.wrappedValue)
					}
				}
				
				Button(action: { self.viewModel.resetWordFields() }) {
					Text("Tap to reset")
						.font(.app.footer)
						.fontWeight(.bold)
						.foregroundColor(.gray)
				}
			}
			.padding()
		}
		.safeAreaInset(edge: .bottom) {
			Button(action: { self.viewModel.importWallet() }) {
				Text("Continue to Import")
			}
			.buttonStyle(ExpandedButtonStyle())
			.disabled(!viewModel.isContinueButtonEnabled)
			.padding()
			.padding(.bottom, 20)
		}
		.background(Color.app.background)
		.edgesIgnoringSafeArea(.bottom)
		.overlay(isShown: viewModel.isLoading) {
			AppProgressView()
		}
		.overlay(isShown: self.viewModel.banner != nil) {
			Color.black.opacity(0.8)
				.banner(data: $viewModel.banner)
		}
		.onChange(of: self.focusedField) { focusedField in
			self.viewModel.focusedField = focusedField
		}
		.onChange(of: self.viewModel.focusedField) { focusedField in
			self.focusedField = focusedField
		}
	}
}

struct ImportSecretPhraseView_Previews: PreviewProvider {
	static var previews: some View {
		ImportSecretPhraseView()
	}
}
