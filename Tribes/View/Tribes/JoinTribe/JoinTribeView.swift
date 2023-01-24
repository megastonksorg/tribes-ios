//
//  JoinTribeView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import SwiftUI

struct JoinTribeView: View {
	@FocusState private var focusedField: ViewModel.Field?
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			TextView("Join a Tribe", style: .pageTitle)
			
			TextView("Enter the pin code that was shared \nwith you below:", style: .pageSubTitle)
				.multilineTextAlignment(.center)
				.padding(.top, SizeConstants.subTitleSpacing)
			
			ZStack {
				TextField("", text: $viewModel.code)
					.focused($focusedField, equals: .pin)
					.keyboardType(.numberPad)
					.background(Color.red)
					.opacity(0)
				
				Button(action: { self.focusedField = .pin }) {
					HStack {
						ForEach(0..<viewModel.codeLimit, id: \.self) { index in
							Spacer()
							RoundedRectangle(cornerRadius: 10)
								.stroke(Color.app.tertiary, lineWidth: 1)
								.frame(dimension: 40)
								.overlay {
									if index < viewModel.code.count {
										Text(String(viewModel.code[index]))
											.font(Font.app.title2)
											.foregroundColor(Color.app.tertiary)
									}
								}
							Spacer()
						}
					}
				}
			}
			.padding(.horizontal)
			.padding(.top, SizeConstants.subTitleSpacing * 2)
			
			Spacer()
			
			Button(action: {}) {
				Text("Join Tribe")
			}
			.buttonStyle(.expanded)
			.disabled(!viewModel.isJoinButtonEnabled)
			.padding(.bottom)
		}
		.pushOutFrame()
		.background(Color.app.background)
		.onAppear { self.focusedField = .pin }
	}
}

struct JoinTribeView_Previews: PreviewProvider {
	static var previews: some View {
		JoinTribeView(viewModel: .init())
	}
}

fileprivate extension StringProtocol {
	subscript(offset: Int) -> Character {
	 self[index(startIndex, offsetBy: offset)]
 }
}
