//
//  DraftView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct DraftView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		if let teaContentVM = viewModel.teaContentVM {
			TeaContentView(viewModel: teaContentVM)
				.overlay(alignment: .topTrailing) {
					Button(action: { viewModel.resetTeaContent() }) {
						Image(systemName: "xmark")
							.font(Font.app.title)
							.foregroundColor(.white)
					}
				}
		}
	}
}

struct DraftView_Previews: PreviewProvider {
	static var previews: some View {
		DraftView(viewModel: .init())
	}
}
