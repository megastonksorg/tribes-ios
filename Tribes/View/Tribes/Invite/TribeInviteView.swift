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
			
			HStack(spacing: 2) {
				Color.clear
					.modifier(NumberView(number: viewModel.code))
				
				Text("-")
					.textCase(.uppercase)
				
				Text("Bombard")
					.textCase(.uppercase)
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
			
			TextView("Pin code will expire in 5 minutes. You need a new pin code for each tribe member", style: .callout)
				.fixedSize(horizontal: false, vertical: true)
			
			Spacer()
			
			Button(action: { viewModel.setRandomNumberTimer() }) {
				TextView("Tap here to generate a new one", style: .bodyTitle)
			}
			.disabled(!viewModel.isCodeReady)
			.opacity(viewModel.isCodeReady ? 1.0 : 0.5)
			.transition(.opacity)
			
			Spacer()
			
			Button(action: { viewModel.setCode(code: 545468) }) {
				Text("Share")
			}
			.buttonStyle(.expanded)
			.padding(.horizontal, 80)
		}
		.multilineTextAlignment(.center)
		.padding()
		.onAppear { viewModel.setRandomNumberTimer() }
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
