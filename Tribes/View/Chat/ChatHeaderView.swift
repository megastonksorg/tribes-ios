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
			let straightDimension: CGFloat = maxWidth * 0.16
			let straightSpacing: CGFloat = maxWidth * 0.04
			switch members.count {
			case 0:
				EmptyView()
			case 1:
				userAvatarView(members[0])
					.frame(dimension: straightDimension)
			case 2:
				HStack(spacing: straightSpacing) {
					Group {
						userAvatarView(members[0])
						userAvatarView(members[1])
					}
					.frame(dimension: straightDimension)
				}
			case 3:
				HStack(spacing: straightSpacing) {
					Group {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
					}
					.frame(dimension: straightDimension)
				}
			case 4:
				HStack(spacing: straightSpacing) {
					Group {
						userAvatarView(members[0])
						userAvatarView(members[1])
						userAvatarView(members[2])
						userAvatarView(members[3])
					}
					.frame(dimension: straightDimension)
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
							TribeMember.noop4
						]
				)
			)
			Spacer()
		}
	}
}
