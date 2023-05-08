//
//  TribeMemberView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-07.
//

import SwiftUI

struct TribeMemberView: View {
	@StateObject var viewModel: TribeMemberView.ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack(spacing: 20) {
			let member: TribeMember = viewModel.member
			UserAvatar(url: member.profilePhoto)
				.frame(dimension: 200)
				.padding(.top)
				
			Text(member.fullName)
				.font(Font.app.title3)
				.foregroundColor(Color.white)
			if let tenure = member.joined.utcToCurrent().date?.timeAgoDisplay() {
				Text("Joined \(tenure)")
					.font(Font.app.footnote)
					.foregroundColor(Color.gray)
					.padding(.bottom)
			}
			Button(action: { viewModel.requestToRemoveTribeMember() }) {
				VStack {
					Image(systemName: "person.fill.badge.minus")
						.font(.system(size: FontSizes.title3))
					Text("Remove")
				}
				.frame(width: 100, height: 50)
				.background(Color.app.secondary, in: Capsule())
			}
			Button(action: { viewModel.requestToBlockTribeMember() }) {
				Text("Block")
					.font(Font.app.body)
					.textCase(.uppercase)
					.foregroundColor(Color.gray)
			}
			.padding(.top)
			Spacer()
		}
		.foregroundColor(Color.white)
		.multilineTextAlignment(.center)
		.pushOutFrame()
		.background(Color.app.background)
	}
}

struct TribeMemberView_Previews: PreviewProvider {
	static var previews: some View {
		TribeMemberView(viewModel: .init(member: TribeMember.noop2, tribe: Tribe.noop2))
	}
}
