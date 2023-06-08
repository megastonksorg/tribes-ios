//
//  NoteComposeView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-31.
//

import SwiftUI

struct NoteComposeView: View {
	
	@FocusState private var focusedField: ViewModel.FocusField?
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		NoteBackgroundView(style: viewModel.backgroundStyle)
			.ignoresSafeArea()
			.onAppear { self.focusedField = .text }
			.onDisappear { self.focusedField = nil }
			.onChange(of: self.focusedField) { viewModel.setFocusedField($0) }
			.onChange(of: self.viewModel.focusField) { self.focusedField = $0 }
			.overlay(
				Color.clear
					.pushOutFrame()
					.contentShape(Rectangle())
					.onTapGesture {
						self.focusedField = .text
					}
			)
			.overlay(
				VStack {
					Spacer()
					TextField("", text: $viewModel.text.max(240), axis: .vertical)
						.tint(Color.white)
						.foregroundColor(.white)
						.multilineTextAlignment(.center)
						.submitLabel(.done)
						.focused($focusedField, equals: .text)
						.onChange(of: viewModel.text) { newValue in
							guard let indexOfNewLine = newValue.firstIndex(of: "\n") else { return }
							viewModel.text.remove(at: indexOfNewLine)
							self.focusedField = nil
						}
						.padding(.horizontal)
						.background {
							if viewModel.isShowingTextHint {
								Text("Write a note")
									.foregroundColor(Color.white.opacity(0.5))
							}
						}
					Spacer()
					backgroundSelector()
						.padding(.bottom)
						.opacity(viewModel.isDoneTyping ? 0.0 : 1.0)
				}
				.font(.system(size: SizeConstants.noteTextSize, weight: .bold, design: .rounded))
			)
	}
	
	@ViewBuilder
	func backgroundSelector() -> some View {
		HStack {
			Spacer()
			ForEach(NoteBackgroundView.Style.allCases) { style in
				HStack {
					Spacer()
					Button(action: { viewModel.setBackgroundStyle(style: style) }) {
						NoteBackgroundView(style: style)
							.clipShape(Circle())
							.frame(dimension: 54)
							.overlay(isShown: style == viewModel.backgroundStyle) {
								Circle()
									.stroke(Color.white, lineWidth: 3)
							}
					}
					.buttonStyle(.insideScaling)
					Spacer()
				}
				
			}
			Spacer()
		}
	}
}

struct NoteComposeView_Previews: PreviewProvider {
	static var previews: some View {
		NoteComposeView(viewModel: .init())
	}
}
