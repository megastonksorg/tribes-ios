//
//  NoteComposeView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-31.
//

import SwiftUI

struct NoteComposeView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		Text("Hello, World!")
	}
}

struct NoteComposeView_Previews: PreviewProvider {
	static var previews: some View {
		NoteComposeView(viewModel: .init())
	}
}
