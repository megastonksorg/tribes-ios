//
//  ImportSecretKeyView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-10.
//

import SwiftUI

struct ImportSecretKeyView: View {
	@FocusState private var focusedField: ViewModel.Field?
	
	@StateObject var viewModel: ViewModel = ViewModel()
	
	@EnvironmentObject var appRouter: AppRouter
		
	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				Text("Type your secret key into each box to login. You must type the key in the correct order for valid authentication")
					.font(Font.app.body)
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
						let isEntryValid: Bool = !word.wrappedValue.isEmpty
						
						TextField(
							"",
							text: word,
							onCommit: { self.viewModel.advanceToNextField() }
						)
						.textInputAutocapitalization(.never)
						.autocorrectionDisabled(true)
						.foregroundColor(.white)
						.font(Font.app.subTitle)
						.multilineTextAlignment(.center)
						.minimumScaleFactor(0.6)
						.lineLimit(1)
						.focused($focusedField, equals: field)
						.padding(.horizontal, 4)
						.background {
							if isEntryValid {
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
						.font(Font.app.footnote)
						.fontWeight(.bold)
						.foregroundColor(.gray)
				}
			}
			.padding()
		}
		.safeAreaInset(edge: .bottom) {
			Button(action: { self.viewModel.importWallet() }) {
				Text("Continue to login")
			}
			.buttonStyle(.expanded)
			.disabled(!viewModel.isContinueButtonEnabled)
			.padding()
			.padding(.bottom, 20)
		}
		.background(Color.app.background)
		.edgesIgnoringSafeArea(.bottom)
		.overlay(isShown: viewModel.isLoading) {
			AppProgressView()
		}
		.banner(data: $viewModel.banner)
		.onChange(of: self.focusedField) { focusedField in
			self.viewModel.focusedField = focusedField
		}
		.onChange(of: self.viewModel.focusedField) { focusedField in
			self.focusedField = focusedField
		}
		.onAppear { self.focusedField = .one }
	}
}

struct ImportSecretKeyView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			ImportSecretKeyView()
		}
	}
}
