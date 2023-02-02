//
//  TribeInviteView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import SwiftUI

struct TribeInviteView: View {
	let dismissAction: () -> ()
	
	@StateObject var viewModel: ViewModel
	
	init(dismissAction: @escaping () -> (), viewModel: ViewModel) {
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
					Button(action: { dismissAction() }) {
						Image(systemName: "x.circle.fill")
							.font(Font.app.title)
							.foregroundColor(Color.white)
					}
					.buttonStyle(.insideScaling)
				}
			)
			
			Spacer()
			
			TextView("Share your pin code for ‘\(viewModel.tribe.name)’ with a tribe member", style: .pageSubTitle)
				.fixedSize(horizontal: false, vertical: true)
			
			Spacer()
			
			ZStack {
				HStack(spacing: 2) {
					Color.clear
						.modifier(NumberView(number: viewModel.pin))
					
					Text("-")
					
					Text(viewModel.code)
						.font(viewModel.code.count < 15 ? Font.app.title2 : Font.app.subTitle)
						.lineLimit(1)
					
					Button(action: {}) {
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
			
			TextView("Pin code will expire in 5 minutes. You need a new pin code for each tribe member", style: .callout)
				.fixedSize(horizontal: false, vertical: true)
			
			Spacer()
			
			Button(action: { viewModel.generatePinCode() }) {
				TextView("Tap here to generate a new one", style: .bodyTitle)
			}
			.disabled(!viewModel.isCodeReady)
			.opacity(viewModel.isCodeReady ? 1.0 : 0.5)
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
					RoundedRectangle(cornerRadius: SizeConstants.cornerRadius)
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
		TribeInviteView(dismissAction: {}, viewModel: .init(tribe: Tribe.noop))
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
			.frame(width: 80)
	}
}
