//
//  TribeInviteView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import SwiftUI

struct TribeInviteView: View {
	let didCopyAction: () -> ()
	let dismissAction: () -> ()
	
	@StateObject var viewModel: ViewModel
	
	init(didCopyAction: @escaping () -> (), dismissAction: @escaping () -> (), viewModel: ViewModel) {
		self.didCopyAction = didCopyAction
		self.dismissAction = dismissAction
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack(spacing: 10) {
			SymmetricHStack(
				content: {
					TextView("Invite Pin Code", style: .pageTitle)
				},
				leading: { EmptyView() },
				trailing: {
					XButton {
						dismissAction()
					}
				}
			)
			
			Spacer()
			Group {
				Text("Share your pin code for ")
				+
				Text(viewModel.tribe.name)
					.foregroundColor(Color.app.tertiary)
				+
				Text(" with a tribe member")
			}
			.fixedSize(horizontal: false, vertical: true)
			.font(Font.app.subHeader)
			.foregroundColor(Color.white)
				
			
			Spacer()
			
			ZStack {
				let font: Font = {
					let wordCount: Int = viewModel.code.count
					if wordCount < 15 {
						return Font.app.title2
					} else if wordCount < 20 {
						return Font.app.subTitle
					} else {
						return Font.app.callout
					}
				}()
				HStack(spacing: 2) {
					Color.clear
						.modifier(NumberView(number: viewModel.pin))
					
					Text("-")
					
					Text(viewModel.code)
						.font(font)
						.lineLimit(1)
					
					Button(
						action: {
							viewModel.copyPinCode()
							didCopyAction()
							}
					) {
						Image(systemName: "doc.on.doc.fill")
							.font(Font.app.title3)
							.foregroundColor(.gray)
					}
					.disabled(!viewModel.isCodeReady)
					.opacity(viewModel.isCodeReady ? 1.0 : 0.5)
					.transition(.opacity)
				}
				.font(Font.app.title2)
				.foregroundColor(.white)
				.textCase(.uppercase)
				.opacity(viewModel.didPinCodeGenerationFail ? 0.0 : 1.0)
				
				TextView("Could Not Generate Pin Code", style: .error)
					.opacity(viewModel.didPinCodeGenerationFail ? 1.0 : 0.0)
			}
			
			TextView("Pin code will expire in 1 hour. You need a new pin code for each tribe member", style: .callout)
				.fixedSize(horizontal: false, vertical: true)
			
			Spacer()
			
			Button(action: { viewModel.generatePinCode() }) {
				TextView("Tap here to generate a new one", style: .bodyTitle)
			}
			.disabled(!viewModel.canRequestNewCode)
			.opacity(viewModel.canRequestNewCode ? 1.0 : 0.5)
			.transition(.opacity)
			
			Spacer()
			
			ShareLink(item: viewModel.shareSheetItem) {
				Text("Share")
				.font(Font.app.title3)
				.textCase(.uppercase)
				.foregroundColor(Color.white)
				.padding()
				.padding(.horizontal)
				.background(
					RoundedRectangle(cornerRadius: SizeConstants.secondaryCornerRadius)
						.fill(Color.app.secondary)
				)
				.fixedSize(horizontal: true, vertical: false)
			}
			.disabled(!viewModel.isCodeReady)
			.opacity(viewModel.isCodeReady ? 1.0 : 0.5)
		
		}
		.multilineTextAlignment(.center)
		.padding()
		.onAppear { viewModel.didAppear() }
		.onDisappear { viewModel.didDisappear() }
	}
}

struct TribeInviteView_Previews: PreviewProvider {
	static var previews: some View {
		TribeInviteView(
			didCopyAction: {},
			dismissAction: {},
			viewModel: .init(tribe: Tribe.noop1)
		)
		.background(Color.black)
	}
}

fileprivate struct NumberView: AnimatableModifier {
	var number: Int

	var animatableData: CGFloat {
		get { CGFloat(number) }
		set { number = Int(newValue) }
	}

	func body(content: Content) -> some View {
		Text(String(format: "%0\(SizeConstants.pinLimit)d", number))
			.foregroundStyle(
				LinearGradient(
					colors: [Color.app.tertiary, Color.app.secondary],
					startPoint: .leading,
					endPoint: .trailing
				)
			)
			.frame(maxWidth: 90, alignment: .trailing)
	}
}
