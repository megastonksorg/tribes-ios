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
					.foregroundStyle(
						LinearGradient(
							colors: [Color.app.tertiary, Color.app.secondary],
							startPoint: .leading,
							endPoint: .trailing
						)
					)
				
				Button(action: {}) {
					Image(systemName: "doc.on.doc.fill")
				}
			}
			.font(Font.app.title2)
			.foregroundColor(.white)
			
			TextView("Code will expire in 5 minutes. You need a new code for each tribe member", style: .callout)
				.fixedSize(horizontal: false, vertical: true)
			
			Spacer()
			
			Button(action: {}) {
				TextView("Tap here to generate a new one", style: .bodyTitle)
			}
			
			Spacer()
			
			Button(action: {}) {
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
