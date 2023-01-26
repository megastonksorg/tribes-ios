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
					TextView("Invite Code", style: .pageTitle)
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
			
			TextView("Share your invite code to ‘\(viewModel.tribe.name)’ with a tribe member", style: .pageSubTitle)
				.fixedSize(horizontal: false, vertical: true)
			
			Spacer()
			
			HStack {
				Text("123456")
					.modifier(NumberView(number: viewModel.code))
				
				Button(action: {}) {
					Image(systemName: "doc.on.doc.fill")
				}
				.disabled(!viewModel.isCopyButtonEnabled)
				.opacity(viewModel.isCopyButtonEnabled ? 1.0 : 0.5)
				.transition(.opacity)
			}
			.font(Font.app.title2)
			.foregroundColor(.white)
			
			TextView("Code will expire in 5 minutes. You need a new code for each tribe member", style: .callout)
				.fixedSize(horizontal: false, vertical: true)
			
			Spacer()
			
			Button(action: { viewModel.setRandomNumberTimer() }) {
				TextView("Tap here to generate a new one", style: .bodyTitle)
			}
			
			Spacer()
			
			Button(action: { viewModel.setCode(code: 545468) }) {
				Text("Share")
			}
			.buttonStyle(.expanded)
			.padding(.horizontal, 80)
		}
		.multilineTextAlignment(.center)
		.padding()
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
		Text(String(format: "%06d", number))
			.foregroundStyle(
				LinearGradient(
					colors: [Color.app.tertiary, Color.app.secondary],
					startPoint: .leading,
					endPoint: .trailing
				)
			)
	}
}
