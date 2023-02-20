//
//  ProfileSettingsView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-13.
//

import SwiftUI

struct ProfileSettingsView: View {
	
	@StateObject private var viewModel: ViewModel
	@FocusState private var focusField: ViewModel.FocusField?
	
	@EnvironmentObject var appRouter: AppRouter
	
	init(viewModel: ProfileSettingsView.ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack(spacing: 20) {
			Group {
				Button(action: { viewModel.selectImageFromLibrary() }) {
					Group {
						if let image = viewModel.image {
							Image(uiImage: image)
								.resizable()
								.aspectRatio(contentMode: .fill)
								.clipShape(Circle())
						}
						else {
							ImagePlaceholderView()
								.opacity(0.4)
								.overlay(
									Color.black.opacity(0.2)
										.overlay(
											Image(systemName: "plus.circle")
												.font(Font.app.title)
												.foregroundColor(.gray)
										)
										.clipShape(Circle())
								)
						}
					}
					.frame(dimension: SizeConstants.profileImageFrame)
				}
				.buttonStyle(.outsideScaling)
				.padding(.top)
			}
			
			Text(self.viewModel.profilePictureTitle)
				.font(Font.app.subTitle)
				.fontWeight(.regular)
				.foregroundColor(.white)
				.padding(.vertical)
			
			TextView(viewModel.nameHintTitle, style: .hint)
			
			TextFieldView(
				title: "Name",
				validation: viewModel.nameValidation,
				onCommit: { self.viewModel.complete() },
				text: $viewModel.name
			)
			.disableAutoCorrection()
			.focused(self.$focusField, equals: .name)
			
			TermsAndConditionsView.StateButton(
				didAcceptTerms: $viewModel.didUserAcceptTerms,
				viewAction: { viewModel.setSheet(sheet: .termsAndConditions) }
			)
			
			Spacer()
		}
		.padding(.horizontal)
		.background(Color.app.background)
		.overlay(isShown: viewModel.isLoading) {
			AppProgressView()
		}
		.banner(data: $viewModel.banner)
		.toolbar {
			ToolbarItem(placement: .principal) {
				AppToolBar(.principal)
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				AppToolBar(
					.trailing,
					trailingClosure: {
						self.viewModel.complete()
						self.focusField = nil
					}
				)
				.disabled(!self.viewModel.isCompletionAllowed)
				.opacity(self.viewModel.isCompletionAllowed ? 1.0 : 0.5)
			}
		}
		.sheet(
			isPresented: Binding(
				get: { viewModel.sheet != nil },
				set: {
					if !$0 {
						viewModel.setSheet(sheet: nil)
					}
				}
			)
		) {
			switch viewModel.sheet {
			case .imagePicker:
				ImagePicker(image: $viewModel.image)
			case .termsAndConditions:
				TermsAndConditionsView()
			default:
				EmptyView()
			}
		}
		.onAppear { self.focusField = .name }
	}
}

struct ProfileEditingView_Previews: PreviewProvider {
	static var previews: some View {
		ProfileSettingsView(viewModel: .init(mode: .creation))
	}
}
