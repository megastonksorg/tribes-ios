//
//  TribeInviteView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import SwiftUI

struct TribeInviteView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack(spacing: 30) {
			SymmetricHStack(
				content: {
					TextView("Invite Code", style: .pageTitle)
				},
				leading: { EmptyView() },
				trailing: {
					Button(action: {}) {
						Image(systemName: "x.circle.fill")
							.font(Font.app.title)
							.foregroundColor(Color.white)
					}
					.padding(.trailing)
				}
			)
			
			TextView("Share your invite code to ‘\(viewModel.tribe.name)’ with a tribe member", style: .pageSubTitle)
			
			HStack {
				Text("123456")
				
				Button(action: {}) {
					Image(systemName: "doc.on.doc.fill")
				}
			}
			.font(Font.app.title2)
			.foregroundColor(.white)
			
			TextView("Code will expire in 5 minutes. You need a new code for each tribe member", style: .callout)
			
			TextView("Tap here to generate a new one", style: .bodyTitle)
			
			Button(action: {}) {
				Text("Share")
			}
			.buttonStyle(.expanded)
			.padding(.horizontal, 100)
		}
		.multilineTextAlignment(.center)
		.padding(.horizontal)
	}
}

struct TribeInviteView_Previews: PreviewProvider {
	static var previews: some View {
		TribeInviteView(viewModel: .init(tribe: Tribe.noop))
			.background(Color.black)
	}
}
