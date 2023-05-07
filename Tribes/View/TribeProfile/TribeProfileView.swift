//
//  TribeProfileView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-07.
//

import SwiftUI

struct TribeProfileView: View {
	@StateObject var viewModel: ViewModel
	
	var body: some View {
		NavigationStack(path: $viewModel.stack) {
			VStack {
				HStack {
					Spacer()
					Button(action: {}) {
						Text("Cancel")
							.font(Font.app.title2)
							.foregroundColor(Color.white)
					}
				}
				.padding(.horizontal)
				
				TribeAvatar(
					context: .profileView,
					tribe: viewModel.tribe,
					size: 200,
					primaryAction: { _ in },
					secondaryAction: { _ in }
				)
				.disabled(true)
				Spacer()
			}
			.pushOutFrame()
			.background(Color.app.background)
		}
	}
}

struct TribeProfile_Previews: PreviewProvider {
	static var previews: some View {
		TribeProfileView(viewModel: .init(tribe: Tribe.noop2))
	}
}
