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
			
			let dimensionB: CGFloat = maxWidth * 0.145
			let spacingB: CGFloat = maxWidth * 0.20
			
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
					.offset(y: -dimensionB * 0.3)
				}
			case 6:
				let spacing: CGFloat = maxWidth * 0.12
				VStack(spacing: 0) {
					HStack(spacing: spacing) {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
					}
					.frame(dimension: dimensionB)
					.offset(x: -dimensionB * 0.4)
					HStack(spacing: spacing) {
						userAvatarView(members[3])
						userAvatarView(members[4])
						userAvatarView(members[5])
					}
					.frame(dimension: dimensionB)
					.offset(x: dimensionB * 0.4, y: -dimensionB * 0.2)
				}
			case 7:
				let dimension: CGFloat = maxWidth * 0.14
				let spacing: CGFloat = maxWidth * 0.08
				VStack(spacing: 0) {
					HStack(spacing: spacing) {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
						userAvatarView(members[3])
					}
					.frame(dimension: dimension)
					HStack(spacing: spacing) {
						userAvatarView(members[4])
						userAvatarView(members[5])
						userAvatarView(members[6])
					}
					.frame(dimension: dimension)
					.offset(y: -dimension * 0.15)
				}
			case 8:
				let dimension: CGFloat = maxWidth * 0.14
				let spacing: CGFloat = maxWidth * 0.08
				VStack(spacing: 0) {
					HStack(spacing: spacing) {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
						userAvatarView(members[3])
					}
					.frame(dimension: dimension)
					.offset(x: -dimension * 0.4)
					HStack(spacing: spacing) {
						userAvatarView(members[4])
						userAvatarView(members[5])
						userAvatarView(members[6])
						userAvatarView(members[7])
					}
					.frame(dimension: dimension)
					.offset(x: dimension * 0.4, y: -dimension * 0.2)
				}
			case 9:
				let dimension: CGFloat = maxWidth * 0.12
				let spacing: CGFloat = maxWidth * 0.08
				VStack(spacing: 6) {
					HStack(spacing: spacing) {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
						userAvatarView(members[3])
						userAvatarView(members[4])
					}
					.frame(dimension: dimension)
					HStack(spacing: spacing) {
						userAvatarView(members[5])
						userAvatarView(members[6])
						userAvatarView(members[7])
						userAvatarView(members[8])
					}
					.frame(dimension: dimension)
					.offset(y: -dimension * 0.15)
				}
			default:
				EmptyView()
			}
		}
		.frame(width: maxWidth, height: 110)
		.background(Color.red)
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
