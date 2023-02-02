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
			if viewModel.stage != .joined {
				TextView(viewModel.pageSubtitle, style: .pageSubTitle)
					.multilineTextAlignment(.center)
					.fixedSize(horizontal: false, vertical: true)
					.padding(.top, SizeConstants.subTitleSpacing)
					.transition(.move(edge: .leading))
			}
			
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
						.onChange(of: viewModel.pin) {
							if $0.count == SizeConstants.pinLimit {
								viewModel.setStage(stage: .code)
							}
						}
					}
					.onAppear { self.focusedField = .pin }
				case .code:
					VStack {
						ZStack {
							Text("CODE WORD")
								.foregroundColor(Color.gray.opacity(viewModel.isShowingCodeHint ? 0.4 : 0.0))
							TextField(
								"",
								text: Binding(
									get: { viewModel.code },
									set: { viewModel.code = $0.uppercased() }
								)
							)
							.tint(Color.app.textFieldCursor)
							.focused($focusedField, equals: .code)
							.keyboardType(.asciiCapable)
							.textInputAutocapitalization(.characters)
							.foregroundColor(Color.white)
							.multilineTextAlignment(.center)
						}
					}
					.font(.system(size: viewModel.codeFontSize, weight: .medium, design: .rounded))
					.padding(.top, 40)
					.onAppear { self.focusedField = .code }
				case .joined:
					if let tribe = viewModel.tribe {
						VStack {
							TextView("You Joined", style: .largeTitle)
							Spacer()
							TribeAvatar(
								tribe: tribe,
								size: 260,
								primaryAction: {_ in},
								secondaryAction: {_ in},
								inviteAction: {_ in},
								leaveAction: {_ in}
							)
							Spacer()
						}
						.padding(.top, 40)
						.onAppear { self.focusedField = nil }
						.onDisappear {  }
					}
				}
			}
			.transition(.move(edge: .leading))
			.padding(.horizontal)
			
			Button(action: { viewModel.setStage(stage: .pin) }) {
				HStack(spacing: 2) {
					Image(systemName: "chevron.backward")
					Text(ViewModel.Stage.pin.rawValue)
						.textCase(.uppercase)
				}
				.font(Font.app.title2)
				.foregroundColor(Color.app.tertiary)
			}
			.padding(.top, 30)
			.opacity(viewModel.stage == .code ? 1.0 : 0.0)
			
			Spacer()
			
			Button(action: { viewModel.proceed() }) {
				Text(viewModel.proceedButtonTitle)
			}
			.buttonStyle(.expanded)
			.disabled(!viewModel.isProceedButtonEnabled)
			.opacity(viewModel.stage == .joined ? 0.0 : 1.0)
			.padding(.bottom)
		}
		.pushOutFrame()
		.overlay(isShown: viewModel.isLoading) {
			AppProgressView()
		}
		.banner(data: self.$viewModel.banner)
		.background(Color.app.background)
		.toolbar {
			ToolbarItem(placement: .principal) {
				AppToolBar(.principal, principalTitle: "Join a Tribe")
			}
		}
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
