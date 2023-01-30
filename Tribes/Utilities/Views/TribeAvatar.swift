//
//  TribeAvatar.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-09.
//

import SwiftUI

struct TribeAvatar: View {
	let name: String
	let members: [TribeMember]
	
	let maxSize: CGFloat
	let nameSize: CGFloat
	let size: CGFloat
	let stackSize: CGFloat
	
	init(tribe: Tribe, size: CGFloat) {
		self.name = tribe.name
		self.members = tribe.members
		self.size = size
		self.maxSize = size * 0.8
		self.stackSize = maxSize * 0.9
		self.nameSize = {
			switch size {
			case 0..<100: return 12
			case 100..<250: return 15
			default: return 20
			}
		}()
	}
	
	var body: some View {
		VStack {
			Circle()
				.fill(Color.app.primary)
				.frame(dimension: size)
				.overlay {
					switch members.count {
					case 1:
						userAvatar(user: members[0])
							.frame(dimension: maxSize)
					case 2:
						let size1: CGFloat = stackSize * 0.4
						let size2: CGFloat = stackSize * 0.6
						VStack(alignment: .leading, spacing: 0) {
							HStack {
								Spacer()
								userAvatar(user: members[0])
									.frame(dimension: size1)
									.offset(y: size1 * 0.2)
							}
							userAvatar(user: members[1])
								.frame(dimension: size2)
						}
						.frame(dimension: stackSize)
					case 3:
						let size1: CGFloat = stackSize * 0.5
						let size2: CGFloat = stackSize * 0.45
						let size3: CGFloat = stackSize * 0.40
						VStack(spacing: 0) {
							Spacer()
							Spacer()
							HStack {
								userAvatar(user: members[0])
									.frame(dimension: size1)
								userAvatar(user: members[1])
									.frame(dimension: size2)
									.offset(y: size2 * 0.2)
							}
							userAvatar(user: members[2])
								.frame(dimension: size3)
						}
						.frame(dimension: stackSize)
					case 4:
						let size1: CGFloat = stackSize * 0.4
						let size2: CGFloat = stackSize * 0.3
						let size3: CGFloat = stackSize * 0.5
						let size4: CGFloat = stackSize * 0.43
						VStack(spacing: 0) {
							HStack {
								userAvatar(user: members[0])
									.frame(dimension: size1)
								userAvatar(user: members[1])
									.frame(dimension: size2)
							}
							Spacer()
							HStack {
								userAvatar(user: members[2])
									.frame(dimension: size3)
								userAvatar(user: members[3])
									.frame(dimension: size4)
									.offset(y: -size4 * 0.2)
							}
						}
						.frame(dimension: stackSize)
					case 5:
						let size1: CGFloat = stackSize * 0.46
						let size2: CGFloat = stackSize * 0.40
						let size3: CGFloat = stackSize * 0.36
						let size4: CGFloat = stackSize * 0.42
						let size5: CGFloat = stackSize * 0.30
						VStack(spacing: 0) {
							HStack {
								userAvatar(user: members[0])
									.frame(dimension: size1)
								userAvatar(user: members[1])
									.frame(dimension: size2)
							}
							Spacer()
							HStack {
								userAvatar(user: members[2])
									.frame(dimension: size3)
									.offset(x: size3 * 0.2, y: -size3 * 0.2)
								userAvatar(user: members[3])
									.frame(dimension: size4)
									.offset(x: size4 * 0.05, y: size4 * 0.2)
								userAvatar(user: members[4])
									.frame(dimension: size5)
									.offset(x: -size5 * 0.2, y: -size5 * 0.5)
							}
						}
						.frame(dimension: stackSize)
					case 6:
						let size1: CGFloat = stackSize * 0.42
						let size2: CGFloat = stackSize * 0.38
						let size3: CGFloat = stackSize * 0.32
						let size4: CGFloat = stackSize * 0.28
						VStack(spacing: 0) {
							userAvatar(user: members[0])
								.frame(dimension: size2)
							HStack {
								userAvatar(user: members[1])
									.frame(dimension: size2)
								userAvatar(user: members[2])
									.frame(dimension: size4)
								userAvatar(user: members[3])
									.frame(dimension: size1)
									.offset(y: -size1 * 0.2)
							}
							HStack {
								userAvatar(user: members[4])
									.frame(dimension: size2)
								userAvatar(user: members[5])
									.frame(dimension: size3)
							}
						}
						.frame(dimension: stackSize)
					case 7:
						let size1: CGFloat = stackSize * 0.38
						let size2: CGFloat = stackSize * 0.36
						let size3: CGFloat = stackSize * 0.32
						HStack(spacing: 0) {
							VStack {
								userAvatar(user: members[0])
									.frame(dimension: size2)
								userAvatar(user: members[1])
									.frame(dimension: size2)
							}

							VStack {
								userAvatar(user: members[2])
									.frame(dimension: size2)
									.offset(x: size2 * 0.2, y: size2 * 0.1)
								userAvatar(user: members[3])
									.frame(dimension: size2)
								userAvatar(user: members[4])
									.frame(dimension: size3)
									.offset(x: -size3 * 0.08)
							}
							
							VStack {
								userAvatar(user: members[5])
									.frame(dimension: size2)
									.offset(x: size2 * 0.1, y: size2 * 0.1)
								userAvatar(user: members[6])
									.frame(dimension: size1)
							}
							.offset(y: size1 * 0.16)
						}
						.frame(dimension: stackSize)
					case 8:
						let size1: CGFloat = stackSize * 0.38
						let size2: CGFloat = stackSize * 0.36
						let size3: CGFloat = stackSize * 0.32
						let size4: CGFloat = stackSize * 0.26
						HStack(spacing: 0) {
							userAvatar(user: members[0])
								.frame(dimension: size4)
								.offset(x: size4 * 0.2)
							VStack {
								userAvatar(user: members[1])
									.frame(dimension: size2)
									.offset(x: -size2 * 0.2, y: size2 * 0.1)
								Spacer()
								userAvatar(user: members[2])
									.frame(dimension: size2)
									.offset(x: -size2 * 0.2)
							}
							
							VStack {
								userAvatar(user: members[3])
									.frame(dimension: size2)
									.offset(x: size2 * 0.05)
								Spacer()
								userAvatar(user: members[4])
									.frame(dimension: size2)
									.offset(x: -size2 * 0.2)
								Spacer()
								userAvatar(user: members[5])
									.frame(dimension: size3)
							}
							.offset(x: -size2 * 0.2)
							
							VStack(spacing: size2 * 0.2) {
								userAvatar(user: members[6])
									.frame(dimension: size2)
									.offset(x: -size2 * 0.2, y: size2 * 0.1)
								userAvatar(user: members[7])
									.frame(dimension: size1)
									.offset(x: -size2 * 0.2)
							}
							.offset(x: -size2 * 0.05)
						}
						.frame(dimension: stackSize)
					case 9:
						let size1: CGFloat = stackSize * 0.36
						let size2: CGFloat = stackSize * 0.32
						let size3: CGFloat = stackSize * 0.26
						HStack(spacing: 0) {
							userAvatar(user: members[0])
								.frame(dimension: size3)
								.offset(x: size3 * 0.2)
							VStack {
								userAvatar(user: members[1])
									.frame(dimension: size1)
									.offset(x: -size1 * 0.2, y: size1 * 0.1)
								Spacer()
								userAvatar(user: members[2])
									.frame(dimension: size1)
									.offset(x: -size1 * 0.2)
							}
							
							VStack {
								userAvatar(user: members[3])
									.frame(dimension: size1)
								Spacer()
								userAvatar(user: members[4])
									.frame(dimension: size1)
									.offset(x: -size1 * 0.3)
								Spacer()
								userAvatar(user: members[5])
									.frame(dimension: size2)
							}
							.offset(x: -size1 * 0.2)
							
							VStack(spacing: size3 * 0.2) {
								userAvatar(user: members[6])
									.frame(dimension: size3)
									.offset(x: -size3 * 0.2, y: size3 * 0.1)
								userAvatar(user: members[7])
									.frame(dimension: size2)
									.offset(x: -size2 * 0.2)
								userAvatar(user: members[8])
									.frame(dimension: size3)
									.offset(x: -size3 * 0.2, y: -size3 * 0.1)
							}
							.offset(x: -size3 * 0.2)
						}
						.frame(dimension: stackSize)
					default:
						let othersCount = members.count - 8
						let size1: CGFloat = stackSize * 0.36
						let size2: CGFloat = stackSize * 0.32
						let size3: CGFloat = stackSize * 0.26
						HStack(spacing: 0) {
							userAvatar(user: members[0])
								.frame(dimension: size3)
								.offset(x: size3 * 0.2)
							VStack {
								userAvatar(user: members[1])
									.frame(dimension: size1)
									.offset(x: -size1 * 0.2, y: size1 * 0.1)
								Spacer()
								userAvatar(user: members[2])
									.frame(dimension: size1)
									.offset(x: -size1 * 0.2)
							}
							
							VStack {
								userAvatar(user: members[3])
									.frame(dimension: size1)
								Spacer()
								Circle()
									.fill(Color.app.secondary)
									.frame(dimension: size1 * 1.2)
									.overlay(
										Text("+\(othersCount)")
											.font(.system(size: nameSize * 1.2))
											.foregroundColor(Color.app.tertiary)
									)
									.offset(x: -size1 * 0.2)
								Spacer()
								userAvatar(user: members[4])
									.frame(dimension: size2)
							}
							.offset(x: -size1 * 0.2)
							
							VStack(spacing: size3 * 0.2) {
								userAvatar(user: members[5])
									.frame(dimension: size3)
									.offset(x: -size3 * 0.2, y: size3 * 0.1)
								userAvatar(user: members[6])
									.frame(dimension: size2)
									.offset(x: -size2 * 0.2)
								userAvatar(user: members[7])
									.frame(dimension: size3)
									.offset(x: -size3 * 0.4, y: -size3 * 0.1)
							}
							.offset(x: -size3 * 0.2)
						}
						.frame(dimension: stackSize)
					}
				}
			TextView(name, style: .tribeName(nameSize))
		}
	}
	
	@ViewBuilder
	func userAvatar(user: TribeMember) -> some View {
		UserAvatar(url: user.profilePhoto)
	}
}

struct TribeAvatar_Previews: PreviewProvider {
	static var previews: some View {
		TribeAvatar(
			tribe: Tribe(
				id: "1",
				name: "Dinner Everyday",
				members: Array(repeating: TribeMember.noop, count: 10)
			),
			size: 200
		)
	}
}
