//
//  MessageTextView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-05.
//

import SwiftUI

struct MessageTextView: View {
	let currentTribeMember: TribeMember
	let sender: TribeMember?
	let style: Message.Style
	let message: Message
	
	@State var isShowingTimeStamp: Bool = false
	
	init(currentTribeMember: TribeMember, message: Message, tribe: Tribe) {
		let sender: TribeMember? = tribe.members[id: message.senderId]
		self.currentTribeMember = currentTribeMember
		self.sender = sender
		self.style = {
			if sender?.id == currentTribeMember.id {
				return .outgoing
			} else {
				return .incoming
			}
		}()
		self.message = message
	}
	
	var body: some View {
		let avatarSize: CGFloat = 42
		let isIncoming: Bool = style == .incoming
		let dummyTribeMember: TribeMember = TribeMember.dummyTribeMember
		HStack(alignment: .top, spacing: 0) {
			Group {
				if let sender = self.sender {
					UserAvatar(url: sender.profilePhoto)
				} else {
					Circle()
						.fill(Color.gray)
				}
			}
			.frame(dimension: avatarSize)
			.opacity(isIncoming ? 1.0 : 0.0)
			Spacer()
				.frame(width: 10)
			if style == .outgoing {
				Spacer(minLength: 0)
			}
			VStack(alignment: .leading, spacing: 4) {
				ZStack(alignment: .leading) {
					Group {
						Text(message.timeStamp, style: .relative)
						+
						Text(" ago")
					}
					.opacity(isShowingTimeStamp ? 1.0 : 0.0)
					Text(isIncoming ? sender?.fullName ?? dummyTribeMember.fullName : "")
						.opacity(isShowingTimeStamp ? 0.0 : 1.0)
				}
				.lineLimit(1)
				.font(Font.app.callout)
				.foregroundColor(Color.gray)
				contentView()
			}
			if style == .incoming {
				Spacer(minLength: 0)
			}
		}
	}
	
	@ViewBuilder
	func contentView() -> some View {
		if let content = message.body?.content {
			Group {
				let corners: UIRectCorner = {
					switch style {
					case .incoming: return [.topRight, .bottomLeft, .bottomRight]
					case .outgoing: return [.topLeft, .topRight, .bottomLeft]
					}
				}()
				
				let color: Color = {
					switch style {
					case .incoming: return Color.app.secondary
					case .outgoing: return Color.app.tertiary
					}
				}()
				
				let foregroundColor: Color = {
					switch style {
					case .incoming: return Color.white
					case .outgoing: return Color.black
					}
				}()
				
				switch content {
				case .text(let text):
					Text(text)
						.font(Font.app.subTitle)
						.foregroundColor(foregroundColor)
						.padding(10)
						.padding(.leading, 6)
						.background(
							CustomRoundedRectangle(cornerRadius: 30, corners: corners)
								.fill(color)
						)
				case .image, .imageData, .video, .systemEvent:
					EmptyView()
				}
			}
			.onTapGesture {
				withAnimation(.easeInOut) {
					self.isShowingTimeStamp = true
					DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
						self.isShowingTimeStamp = false
					}
				}
			}
		}
	}
}

struct MessageTextView_Previews: PreviewProvider {
	static var previews: some View {
		MessageTextView(currentTribeMember: TribeMember.noop1, message: Message.noopEncryptedTextChat, tribe: Tribe.noop1)
	}
}
