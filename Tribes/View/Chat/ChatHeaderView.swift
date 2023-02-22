//
//  ChatHeaderView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-21.
//

import IdentifiedCollections
import SwiftUI

struct ChatHeaderView: View {
	let maxWidth: CGFloat = UIScreen.main.bounds.width
	
	let members: IdentifiedArrayOf<TribeMember>
	var body: some View {
		HStack() {
			let dimensionA: CGFloat = maxWidth * 0.16
			let spacingA: CGFloat = maxWidth * 0.04
			
			let dimensionB: CGFloat = maxWidth * 0.14
			let spacingB: CGFloat = maxWidth * 0.2
			
			switch members.count {
			case 0:
				EmptyView()
			case 1:
				userAvatarView(members[0])
					.frame(dimension: dimensionA)
			case 2:
				HStack(spacing: spacingA) {
					Group {
						userAvatarView(members[0])
						userAvatarView(members[1])
					}
					.frame(dimension: dimensionA)
				}
			case 3:
				HStack(spacing: spacingA) {
					Group {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
					}
					.frame(dimension: dimensionA)
				}
			case 4:
				HStack(spacing: spacingA) {
					Group {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
						userAvatarView(members[3])
					}
					.frame(dimension: dimensionA)
				}
			case 5:
				VStack(spacing: 0) {
					HStack(spacing: spacingB) {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
					}
					.frame(dimension: dimensionB)
					HStack(spacing: spacingB) {
						userAvatarView(members[3])
						userAvatarView(members[4])
					}
					.frame(dimension: dimensionB)
					.offset(y: -dimensionB/2.4)
				}
			default:
				EmptyView()
			}
		}
		.frame(width: maxWidth, height: 100)
		.background(Color.black)
	}
	
	@ViewBuilder
	func userAvatarView(_ member: TribeMember) -> some View {
		Button(action: {}) {
			UserAvatar(url: member.profilePhoto)
		}
	}
}

struct ChatHeaderView_Previews: PreviewProvider {
	static var previews: some View {
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
						]
				)
			)
			Spacer()
		}
	}
}
