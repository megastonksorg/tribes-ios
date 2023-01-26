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
			TextView(viewModel.pageSubtitle, style: .pageSubTitle)
				.multilineTextAlignment(.center)
				.padding(.top, SizeConstants.subTitleSpacing)
				.transition(.move(edge: .leading))
			
			Group {
				switch viewModel.stage {
				case .pin:
					VStack {
						Button(action: { viewModel.pasteCode() }) {
							HStack {
								Text("Paste")
								Image(systemName: "doc.on.clipboard")
							}
							.foregroundColor(Color.app.tertiary)
							.padding(.top, 20)
							.opacity(viewModel.isShowingPasteButton ? 1.0 : 0.0)
						}
						ZStack {
							TextField(
								"",
								text: Binding(
									get: { viewModel.pin },
									set: { if $0.count <= SizeConstants.pinLimit { viewModel.pin = $0 } }
								)
							)
							.focused($focusedField, equals: .pin)
							.keyboardType(.numberPad)
							.background(Color.red)
							.opacity(0)
							
							Button(action: {
								self.focusedField = .pin
								viewModel.pinFieldTapped()
							}) {
								HStack {
									ForEach(0..<SizeConstants.pinLimit, id: \.self) { index in
										Spacer()
										RoundedRectangle(cornerRadius: 10)
											.stroke(Color.app.tertiary, lineWidth: 1)
											.frame(dimension: 40)
											.overlay {
												if index < viewModel.pin.count {
													Text(String(viewModel.pin[index]))
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
					}
				case .code:
					EmptyView()
				}
			}
			
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
		.toolbar {
			ToolbarItem(placement: .principal) {
				AppToolBar(.principal, principalTitle: "Join a Tribe")
			}
		}
		.onAppear { self.focusedField = .pin }
	}
}

struct JoinTribeView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			JoinTribeView(viewModel: .init())
		}
	}
}

fileprivate extension StringProtocol {
	subscript(offset: Int) -> Character {
	 self[index(startIndex, offsetBy: offset)]
 }
}
