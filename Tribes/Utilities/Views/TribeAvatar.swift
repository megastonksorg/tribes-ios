//
//  TribeAvatar.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-09.
//

import SwiftUI

struct TribeAvatar: View {
	let members: [TribeMember]
	let size: CGFloat
	
	var body: some View {
		Circle()
			.fill(Color.app.primary)
			.frame(dimension: size)
			.overlay {
				switch members.count {
				case 1:
					asyncImage(user: members[0])
						.frame(dimension: size * 0.8)
				case 2:
					Circle()
				default:
					Circle()
				}
			}
	}
	
	@ViewBuilder
	func asyncImage(user: TribeMember) -> some View {
		AsyncImage(url: user.photoURL,
		content: { image in
			image
				.resizable()
				.scaledToFill()
				.clipShape(Circle())
		}, placeholder: {
			Circle()
				.fill(Color.black.opacity(0.6))
				.overlay(ProgressView())
		})
	}
}

struct TribeAvatar_Previews: PreviewProvider {
	static var previews: some View {
		TribeAvatar(
			members: Array(
				repeating: TribeMember.noop,
				count: 1
			),
			size: 200
		)
	}
}
