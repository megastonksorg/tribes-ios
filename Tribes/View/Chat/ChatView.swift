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
						lineWidth: 2
					)
			)
			.padding(.horizontal, 4)
			
			VStack{
				HStack {
					Text("Yes")
					Spacer()
				}
			}
			.frame(height: 80)
			.padding(.horizontal)
		}
		.pushOutFrame()
		.background(Color.app.background)
	}
}

struct ChatView_Previews: PreviewProvider {
	static var previews: some View {
		ChatView(viewModel: .init(tribe: Tribe.noop2))
	}
}
