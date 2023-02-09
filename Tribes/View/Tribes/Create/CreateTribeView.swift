//
//  CreateTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-23.
//

import SwiftUI

struct CreateTribeView: View {
	@FocusState var focusedField: ViewModel.Field?
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			TextView("Add a name  to represent your Tribe", style: .pageSubTitle)
				.padding(.top, SizeConstants.subTitleSpacing)
			
			TextFieldView(title: "Name", text: $viewModel.name)
				.focused($focusedField, equals: .name)
				.padding(.horizontal)
				.padding(.top, SizeConstants.subTitleSpacing * 2)
			
			Spacer()
			
			Button(action: { viewModel.createTribe() }) {
				Text("Create Tribe")
			}
			.buttonStyle(.expanded)
			.disabled(!viewModel.isCreateButtonEnabled)
			.padding(.bottom)
		}
		.pushOutFrame()
		.background(Color.app.background)
		.toolbar {
			ToolbarItem(placement: .principal) {
				AppToolBar(.principal, principalTitle: "Create a Tribe")
			}
		}
		.banner(data: self.$viewModel.banner)
		.onAppear { self.focusedField = .name }
	}
}

struct CreateTribeView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			CreateTribeView(viewModel: .init())
		}
	}
}
