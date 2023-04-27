//
//  ChatHeaderView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-21.
//

import IdentifiedCollections
import SwiftUI

struct ChatHeaderView: View {
	let members: IdentifiedArrayOf<TribeMember>
	
	var body: some View {
		let limit: Int = 10
		let spacing: CGFloat = 6
		let dimension: CGFloat = 36
		HStack(spacing: -spacing) {
			ForEach(members.prefix(limit)) {
				UserAvatar(url: $0.profilePhoto)
					.frame(dimension: dimension)
			}
			if members.count > limit {
				Circle()
					.fill(Color.app.secondary)
					.frame(dimension: dimension)
					.overlay(
						Text("+\(members.count - limit)")
							.font(Font.app.title3)
							.foregroundColor(Color.white)
					)
			}
		}
	}
}

struct ChatHeaderView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			VStack {
				ChatHeaderView(
					members: IdentifiedArrayOf(
						uniqueElements:
							[
								TribeMember.noop1,
								TribeMember.noop2,
								TribeMember.noop3,
								TribeMember.noop4,
								TribeMember.noop5,
								TribeMember.noop6,
								TribeMember.noop7,
								TribeMember.noop8,
								TribeMember.noop9
							]
					)
				)
				Spacer()
			}
		}
	}
}
