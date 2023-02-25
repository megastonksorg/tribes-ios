//
//  ChatMessageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-23.
//

import SwiftUI

struct ChatMessageView: View {
	let message: ChatMessage
	
	@State var isShowingTimeStamp: Bool = false
	
	var body: some View {
		let avatarSize: CGFloat = 42
		let isIncoming: Bool = message.style == .incoming
		HStack(alignment: .top, spacing: 0) {
			UserAvatar(url: message.sender.profilePhoto)
				.frame(dimension: avatarSize)
				.opacity(isIncoming ? 1.0 : 0.0)
			Spacer()
				.frame(width: 10)
			if message.style == .outgoing {
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
					Text(isIncoming ? message.sender.fullName : "")
						.opacity(isShowingTimeStamp ? 0.0 : 1.0)
				}
				.lineLimit(1)
				.font(Font.app.callout)
				.foregroundColor(Color.gray)
				contentView()
			}
			if message.style == .incoming {
				Spacer(minLength: 0)
			}
		}
	}
	
	@ViewBuilder
	func contentView() -> some View {
		Group {
			switch message.content {
			case .text:
				textView(content: message.content)
			case .imageWithCaption, .videoWithCaption:
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
	
	@ViewBuilder
	func textView(content: ChatMessage.Content) -> some View {
		let corners: UIRectCorner = {
			switch message.style {
			case .incoming: return [.topRight, .bottomLeft, .bottomRight]
			case .outgoing: return [.topLeft, .topRight, .bottomLeft]
			}
		}()
		
		let color: Color = {
			switch message.style {
			case .incoming: return Color.app.secondary
			case .outgoing: return Color.app.tertiary
			}
		}()
		
		let foregroundColor: Color = {
			switch message.style {
			case .incoming: return Color.white
			case .outgoing: return Color.black
			}
		}()
		
		if case .text(let text) = content {
			let isEncrypted: Bool = text == nil
			Text(text ?? "Message Could not decrypted")
				.font(Font.app.subTitle)
				.foregroundColor(foregroundColor)
				.padding(10)
				.padding(.leading, 6)
				.blur(radius: isEncrypted ? 4.0 : 0.0)
				.background(
					CustomRoundedRectangle(cornerRadius: 30, corners: corners)
						.fill(color)
				)
				.overlay(isShown: isEncrypted) {
					Image(systemName: "lock.circle.fill")
						.symbolRenderingMode(.palette)
						.foregroundStyle(Color.app.secondary, Color.white)
						.font(.system(size: 40))
				}
		}
	}
}

struct ChatMessageView_Previews: PreviewProvider {
	static var previews: some View {
		ChatMessageView(message: ChatMessage.noop4)
	}
}
