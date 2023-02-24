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
		let spacing: CGFloat = 10
		HStack(alignment: .top) {
			UserAvatar(url: message.sender.profilePhoto)
				.frame(dimension: avatarSize)
			Spacer()
				.frame(width: spacing)
			VStack(alignment: .leading, spacing: 4) {
				ZStack(alignment: .leading) {
					Group {
						Text(message.timeStamp, style: .relative)
						+
						Text(" ago")
					}
					.opacity(isShowingTimeStamp ? 1.0 : 0.0)
					Text(message.sender.fullName)
						.opacity(isShowingTimeStamp ? 0.0 : 1.0)
				}
				.font(Font.app.callout)
				.foregroundColor(Color.gray)
				contentView()
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
	
	@ViewBuilder
	func contentView() -> some View {
		switch message.content {
		case .text:
			textView(content: message.content)
		case .imageWithCaption, .videoWithCaption:
			EmptyView()
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
				.padding()
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
		ChatMessageView(message: ChatMessage.noop1)
	}
}
