//
//  ChatView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import SwiftUI

struct ChatView: View {
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	var body: some View {
		VStack {
			VStack {
				HStack {
					Spacer()
				}
				Text("Message")
					.foregroundColor(.white)
				Spacer()
			}
			.background(
				CalloutRectangle(calloutRadius: 6, radius: 20)
					.stroke(
						LinearGradient(
							colors: [.clear, .clear, .clear, .clear, Color.app.secondary],
							startPoint: .top,
							endPoint: .bottom
						),
						lineWidth: 1.5
					)
			)
			.padding(.horizontal, 4)
			
			Spacer()
				.frame(height: 14)
			
			VStack{
				HStack {
					Spacer()
					TribeAvatar(
						tribe: viewModel.tribe,
						size: 80,
						avatarContextAction: { _ in },
						primaryAction: { _ in },
						secondaryAction: { _ in },
						inviteAction: { _ in },
						leaveAction: { _ in }
					)
				}
			}
			.padding([.horizontal, .bottom])
		}
		.pushOutFrame()
		.background(Color.app.background)
		.ignoresSafeArea()
	}
}

struct ChatView_Previews: PreviewProvider {
	static var previews: some View {
		ChatView(viewModel: .init(tribe: Tribe.noop2))
	}
}
