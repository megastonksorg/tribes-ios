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
	
	var stackSize: CGFloat {
		maxSize * 0.9
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
					.frame(dimension: stackSize)
				case 3:
					let size1: CGFloat = maxSize * 0.5
					let size2: CGFloat = maxSize * 0.45
					let size3: CGFloat = maxSize * 0.40
					VStack(spacing: 0) {
						Spacer()
						Spacer()
						HStack {
							asyncImage(user: members[0])
								.frame(dimension: size1)
							asyncImage(user: members[1])
								.frame(dimension: size2)
								.offset(y: size2 * 0.2)
						}
						asyncImage(user: members[2])
							.frame(dimension: size3)
					}
					.frame(dimension: stackSize)
				case 4:
					let size1: CGFloat = maxSize * 0.4
					let size2: CGFloat = maxSize * 0.3
					let size3: CGFloat = maxSize * 0.5
					let size4: CGFloat = maxSize * 0.43
					VStack(spacing: 0) {
						HStack {
							asyncImage(user: members[0])
								.frame(dimension: size1)
							asyncImage(user: members[1])
								.frame(dimension: size2)
						}
						Spacer()
						HStack {
							asyncImage(user: members[2])
								.frame(dimension: size3)
							asyncImage(user: members[3])
								.frame(dimension: size4)
								.offset(y: -size4 * 0.2)
						}
					}
					.frame(dimension: stackSize)
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
				count: 4
			),
			size: 200
		)
	}
}
