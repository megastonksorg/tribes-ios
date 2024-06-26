//
//  TribeAvatar.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-09.
//

import IdentifiedCollections
import SwiftUI

struct TribeAvatar: View {
	enum Context: Equatable {
		case tribesView
		case profileView
		case draftView(_ isSelected: Bool)
	}
	
	let context: Context
	let name: String
	let members: IdentifiedArrayOf<TribeMember>
	let tribe: Tribe
	
	let maxSize: CGFloat
	let nameSize: CGFloat
	let size: CGFloat
	let stackSize: CGFloat
	
	let longPressMinimumDuration: CGFloat
	
	let avatarContextAction: (_ tribe: Tribe) -> ()
	let nameContextAction: (_ tribe: Tribe) -> ()
	let primaryAction: (_ tribe: Tribe) -> ()
	let secondaryAction: (_ tribe: Tribe) -> ()
	
	var isInviteButtonEnabled: Bool {
		tribe.members.count <= 10
	}
	
	var lastChat: Message? {
		messageClient.tribesMessages[id: tribe.id]?.chat.last
	}
	
	var hasTea: Bool {
		!(messageClient.tribesMessages[id: tribe.id]?.tea.isEmpty ?? true)
	}
	
	var isUploadingTea: Bool {
		!(messageClient.tribesMessages[id: tribe.id]?.teaDrafts.isEmpty ?? true)
	}
	
	var messagesCount: Int {
		messageClient.tribesMessages[id: tribe.id]?.messages.count ?? 0
	}
	
	@ObservedObject var messageClient: MessageClient = MessageClient.shared
	
	@State var hasUnreadTea: Bool = false
	@State var hasUnreadChat: Bool = false
	
	init(
		context: Context,
		tribe: Tribe,
		size: CGFloat,
		avatarContextAction: @escaping (_ tribe: Tribe) -> () = { _ in },
		nameContextAction: @escaping (_ tribe: Tribe) -> () = { _ in },
		primaryAction: @escaping (_ tribe: Tribe) -> (),
		secondaryAction: @escaping (_ tribe: Tribe) -> ()
	) {
		self.context = context
		self.name = tribe.name
		self.members = context == .profileView ? tribe.members : tribe.members.others
		self.tribe = tribe
		
		self.size = size
		self.maxSize = size * 0.8
		self.stackSize = maxSize * 0.9
		self.nameSize = { size.getTribeNameSize() }()
		
		self.longPressMinimumDuration = 0.5
		
		self.avatarContextAction = avatarContextAction
		self.nameContextAction = nameContextAction
		self.primaryAction = primaryAction
		self.secondaryAction = secondaryAction
	}
	
	var body: some View {
		VStack {
			Button(action: { primaryAction(self.tribe) }) {
				avatarBackground()
					.frame(dimension: size)
					.overlay {
						switch members.count {
						case 0:
							let fontSize: CGFloat = size * 0.15
							VStack(spacing: 10) {
								Spacer()
								Image(systemName: "person.3.fill")
									.font(.system(size: fontSize))
									.foregroundColor(Color.white)
								Spacer()
							}
							.frame(maxWidth: .infinity)
							.overlay(alignment: .center) {
								HStack {
									TextView("Assemble Your Tribe", style: .tribeName(fontSize * 0.4, true))
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
							let size1: CGFloat = stackSize * 0.60
							let size2: CGFloat = stackSize * 0.50
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
								Spacer(minLength: 0)
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
					.overlay {
						switch context {
						case .tribesView, .profileView, .draftView(false):
							EmptyView()
						case .draftView(true):
							ZStack {
								Circle()
									.fill(Color.app.primary.opacity(0.8))
								Circle()
									.stroke(Color.app.secondary, lineWidth: 4)
								Image(systemName: "checkmark")
									.font(.system(size: FontSizes.body))
									.foregroundColor(Color.white)
									.padding(4)
									.background(Color.app.secondary, in: Circle())
							}
						}
					}
			}
			.buttonStyle(.insideScaling)
			.if(context == .tribesView) { view in
				view
					.simultaneousGesture(
						LongPressGesture(minimumDuration: longPressMinimumDuration)
							.onEnded { _ in
								avatarContextAction(self.tribe)
							}
					)
			}
			.overlay(isShown: context == .tribesView && hasUnreadChat , alignment: .top) {
				if let lastChat = self.lastChat {
					if lastChat.senderId != self.tribe.members.currentMember?.id {
						if case .systemEvent(let textContent) = lastChat.encryptedBody.content {
							callOutIndicator(content: textContent, style: .alternate)
						} else {
							switch lastChat.body?.content {
							case .text(let textContent):
								callOutIndicator(content: textContent, style: .regular)
							case .image, .imageData, .video, .note, .systemEvent, .none:
								EmptyView()
							}
						}
					}
				}
			}
			switch context {
			case .tribesView, .draftView:
				TribeNameView(name: name, shouldShowChevron: context == .tribesView, fontSize: nameSize, action: { secondaryAction(self.tribe) })
					.simultaneousGesture(
						LongPressGesture(minimumDuration: longPressMinimumDuration)
							.onEnded { _ in
								nameContextAction(self.tribe)
							}
					)
			case .profileView:
				EmptyView()
			}
		}
		.onAppear { self.checkForUnreadTea() }
		.onChange(of: self.messagesCount) { _ in self.checkForUnreadTea() }
		.onChange(of: self.messageClient.readMessage) { _ in self.checkForUnreadTea() }
	}
	
	@ViewBuilder
	func userAvatar(user: TribeMember) -> some View {
		UserAvatar(url: user.profilePhoto)
	}
	
	@ViewBuilder
	func avatarBackground() -> some View {
		switch self.context {
		case .tribesView, .draftView:
			let lineWidth: CGFloat = size * 0.03
			ZStack {
				Circle()
					.fill(Color.app.primary)
				Circle()
					.stroke(Color(uiColor: UIColor(hex: "561504")), lineWidth: lineWidth)
					.opacity(hasTea ? 1.0 : 0.0)
				Circle()
					.stroke(Color.app.secondary, lineWidth: lineWidth)
					.opacity(hasUnreadTea || isUploadingTea ? 1.0 : 0.0)
					.transition(.opacity)
				if isUploadingTea {
					LoadingIndicator(
						speed: 0.2,
						style: .tribeAvatar,
						lineWidth: lineWidth,
						trim: 0.2
					)
				}
			}
		case .profileView:
			Circle()
				.fill(Color.clear)
		}
	}
	
	@ViewBuilder
	func callOutIndicator(content: String, style: CalloutView.Style) -> some View {
		Button(action: { secondaryAction(self.tribe) }) {
			CalloutView(content: content, style: style, fontSize: nameSize * 0.9)
				.offset(y: -size * 0.1)
		}
		.buttonStyle(.plain)
	}
	
	func checkForUnreadTea() {
		if self.context == .tribesView {
			Task {
				guard let tea = self.messageClient.tribesMessages[id: tribe.id]?.tea else { return }
				let teaIds = tea.map { $0.id }
				let unreadIds = Set(teaIds).subtracting(messageClient.readMessage)
				if unreadIds.count > 0 {
					self.hasUnreadTea = true
				} else {
					self.hasUnreadTea = false
				}
			}
			Task {
				guard let chat = self.messageClient.tribesMessages[id: tribe.id]?.chat else { return }
				let chatIds = chat.map { $0.id }
				let unreadIds = Set(chatIds).subtracting(messageClient.readMessage)
				if unreadIds.count > 0 {
					self.hasUnreadChat = true
				} else {
					self.hasUnreadChat = false
				}
			}
		}
	}
}

struct TribeNameView: View {
	let name: String
	let shouldShowEditIcon: Bool
	let shouldShowChevron: Bool
	let fontSize: CGFloat
	let action: () -> ()
	
	init(
		name: String,
		shouldShowEditIcon: Bool = false,
		shouldShowChevron: Bool = false,
		fontSize: CGFloat,
		action: @escaping () -> Void
	) {
		self.name = name
		self.shouldShowEditIcon = shouldShowEditIcon
		self.shouldShowChevron = shouldShowChevron
		self.fontSize = fontSize
		self.action = action
	}
	
	var body: some View {
		Button(action: { action() }) {
			HStack {
				TextView(name, style: .tribeName(fontSize, false))
				if shouldShowEditIcon {
					Image(systemName: AppConstants.editIcon)
						.font(.system(size: fontSize, weight: .black))
						.foregroundColor(Color.app.tertiary)
						.padding(4)
						.padding(.vertical, 4)
						.background(Circle().fill(Color.gray.opacity(0.01)))
				}
				if shouldShowChevron {
					Image(systemName: "chevron.right")
						.font(.system(size: fontSize, weight: .black))
						.foregroundColor(Color.app.tertiary)
				}
			}
			.background(Color.black.opacity(0.01))
		}
		.fixedSize(horizontal: false, vertical: true)
	}
}

struct TribeAvatar_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			HStack {
				TribeAvatar(
					context: .profileView,
					tribe: Tribe(
						id: "1",
						name: "Body does not Lie. But do not for one second think that this is",
						timestampId: "stamp",
						members: [
							TribeMember.noop1,
							TribeMember.noop2,
							TribeMember.noop3,
							TribeMember.noop4
						]
					),
					size: 180,
					avatarContextAction: { _ in },
					primaryAction: { _ in },
					secondaryAction: { _ in }
				)
				Spacer()
				TribeAvatar(
					context: .draftView(true),
					tribe: Tribe(
						id: "1",
						name: "Body does not Lie. But do not think that I would",
						timestampId: "stamp",
						members: [
							TribeMember.noop1,
							TribeMember.noop2,
							TribeMember.noop3,
							TribeMember.noop4,
							TribeMember.noop5,
							TribeMember.noop6
						]
					),
					size: 80,
					avatarContextAction: { _ in },
					primaryAction: { _ in },
					secondaryAction: { _ in }
				)
			}
		}
	}
}
