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
				let tribeAvatarSize: CGFloat = 80
				HStack {
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack(alignment: .bottom) {
							ForEach(viewModel.tribe.members) { member in
								memberAvatar(member: member)
							}
						}
					}
					.frame(maxHeight: tribeAvatarSize + 20)
					Spacer()
					TribeAvatar(
						tribe: viewModel.tribe,
						size: tribeAvatarSize,
						avatarContextAction: { _ in },
						primaryAction: { _ in },
						secondaryAction: { _ in },
						inviteAction: { _ in },
						leaveAction: { _ in }
					)
				}
			}
			.padding([.horizontal, .bottom])
			.offset(x: 2)
		}
		.pushOutFrame()
		.background(Color.app.background)
		.ignoresSafeArea()
	}
	
	@ViewBuilder
	func memberAvatar(member: TribeMember) -> some View {
		VStack {
			Spacer()
			UserAvatar(url: member.profilePhoto)
				.frame(dimension: 50)
			Spacer()
			Text(member.fullName)
				.font(.system(size: FontSizes.footnote, weight: .semibold))
				.foregroundColor(Color.gray)
		}
	}
}

struct ChatView_Previews: PreviewProvider {
	static var previews: some View {
		ChatView(viewModel: .init(tribe: Tribe.noop2))
	}
}
