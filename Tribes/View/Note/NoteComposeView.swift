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
			.overlay(
				Color.clear
					.pushOutFrame()
					.contentShape(Rectangle())
					.onTapGesture {
						self.focusedField = .text
					}
			)
			.overlay(
				TextField("", text: $viewModel.text.max(200), axis: .vertical)
					.font(.system(size: SizeConstants.noteTextSize, weight: .bold, design: .rounded))
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
			)
	}
}

struct NoteComposeView_Previews: PreviewProvider {
	static var previews: some View {
		NoteComposeView(viewModel: .init())
	}
}
