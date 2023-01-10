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
	
	var maxSize: CGFloat {
		size * 0.8
	}
	
	var body: some View {
		Circle()
			.fill(Color.app.primary)
			.frame(dimension: size)
			.overlay {
				switch members.count {
				case 1:
					asyncImage(user: members[0])
						.frame(dimension: maxSize)
				case 2:
					let size1: CGFloat = maxSize * 0.4
					let size2: CGFloat = maxSize * 0.6
					VStack(alignment: .leading, spacing: 0) {
						HStack {
							Spacer()
							asyncImage(user: members[0])
								.frame(dimension: size1)
								.offset(y: size1 * 0.2)
						}
						asyncImage(user: members[1])
							.frame(dimension: size2)
					}
					.frame(dimension: maxSize * 0.9)
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
				count: 2
			),
			size: 200
		)
	}
}
