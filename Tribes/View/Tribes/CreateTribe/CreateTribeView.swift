//
//  CreateTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-23.
//

import SwiftUI

struct CreateTribeView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			TextView("Create a Tribe", style: .pageTitle)
			
			TextView("Add a name  to represent your Tribe", style: .pageSubTitle)
				.padding(.top, SizeConstants.subTitleSpacing)
			
			TextFieldView(title: "Name", text: $viewModel.name)
				.padding(.horizontal)
				.padding(.top, SizeConstants.subTitleSpacing * 2)
			
			Spacer()
			
			Button(action: {}) {
				Text("Create Tribe")
			}
			.buttonStyle(.expanded)
			.disabled(!viewModel.isCreateButtonEnabled)
			.padding(.bottom)
		}
		.pushOutFrame()
		.background(Color.app.background)
	}
}

struct CreateTribeView_Previews: PreviewProvider {
	static var previews: some View {
		CreateTribeView(viewModel: .init())
	}
}
