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
	let tribe: Tribe
	
	let maxSize: CGFloat
	let nameSize: CGFloat
	let size: CGFloat
	let stackSize: CGFloat
	
	let showName: Bool
	
	let contextAction: (_ tribe: Tribe) -> ()
	let primaryAction: (_ tribe: Tribe) -> ()
	let secondaryAction: (_ tribe: Tribe) -> ()
	let inviteAction: (_ tribe: Tribe) -> ()
	let leaveAction: (_ tribe: Tribe) -> ()
	
	var isInviteButtonEnabled: Bool {
		members.count + 1 <= 10
	}
	
	init(
		tribe: Tribe,
		size: CGFloat,
		showName: Bool = true,
		contextAction: @escaping (_ tribe: Tribe) -> (),
		primaryAction: @escaping (_ tribe: Tribe) -> (),
		secondaryAction: @escaping (_ tribe: Tribe) -> (),
		inviteAction: @escaping (_ tribe: Tribe) -> (),
		leaveAction: @escaping (_ tribe: Tribe) -> ()
	) {
		self.name = tribe.name
		self.members = {
			if let currentUser: User = KeychainClient.shared.get(key: .user) {
				return tribe.members.filter({ $0.walletAddress != currentUser.walletAddress })
			}
			return tribe.members
		}()
		self.tribe = tribe
		
		self.size = size
		self.maxSize = size * 0.8
		self.stackSize = maxSize * 0.9
		self.nameSize = {
			switch size {
			case 0..<100: return 12
			case 100..<250: return 15
			case 250..<400: return 18
			default: return 22
			}
		}()
		
		self.showName = showName
		
		self.contextAction = contextAction
		self.primaryAction = primaryAction
		self.secondaryAction = secondaryAction
		self.inviteAction = inviteAction
		self.leaveAction = leaveAction
	}
	
	var body: some View {
		VStack {
			Button(action: { primaryAction(self.tribe) }) {
				Circle()
					.fill(Color.app.primary)
					.frame(dimension: size)
					.overlay {
						switch members.count {
						case 0:
							let fontSize: CGFloat = size * 0.15
							VStack(spacing: 10) {
								Spacer()
								Image(systemName: "person.3.fill")
									.font(.system(size: fontSize))
									.foregroundColor(Color.app.tertiary)
								Spacer()
							}
							.frame(maxWidth: .infinity)
							.overlay(alignment: .center) {
								HStack {
									TextView("Assemble Your Tribe", style: .tribeName(fontSize * 0.4))
										.offset(y: fontSize)
								}
							}
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
			}
			.buttonStyle(.insideScaling)
			if self.showName {
				TribeNameView(name: name, fontSize: nameSize, action: { secondaryAction(self.tribe) })
			}
		}
		.simultaneousGesture(
			LongPressGesture(minimumDuration: 0.5)
				.onEnded { _ in
					contextAction(self.tribe)
				}
		)
	}
	
	@ViewBuilder
	func userAvatar(user: TribeMember) -> some View {
		UserAvatar(url: user.profilePhoto)
	}
}

struct TribeNameView: View {
	let name: String
	let shouldShowEditIcon: Bool = false
	let fontSize: CGFloat
	let action: () -> ()
	
	var body: some View {
		Button(action: { action() }) {
			TextView(name, style: .tribeName(fontSize))
				.fixedSize(horizontal: false, vertical: true)
			if shouldShowEditIcon {
				Image(systemName: "pencil.line")
					.font(.system(size: fontSize, weight: .black))
					.foregroundColor(Color.app.tertiary)
			}
		}
		.buttonStyle(.insideScaling)
	}
}

struct TribeAvatar_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			HStack {
				TribeAvatar(
					tribe: Tribe(
						id: "1",
						name: "Body does not Lie. But do not for one second think that this is",
						members: Array(repeating: TribeMember.noop1, count: 10)
					),
					size: 180,
					contextAction: { _ in },
					primaryAction: { _ in },
					secondaryAction: { _ in },
					inviteAction: {_ in },
					leaveAction: { _ in }
				)
				Spacer()
				TribeAvatar(
					tribe: Tribe(
						id: "1",
						name: "Body does not Lie. But do not think that I would",
						members: Array(repeating: TribeMember.noop1, count: 10)
					),
					size: 180,
					showName: false,
					contextAction: { _ in },
					primaryAction: { _ in },
					secondaryAction: { _ in },
					inviteAction: { _ in },
					leaveAction: { _ in }
				)
			}
		}
	}
}
