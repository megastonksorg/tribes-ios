//
//  ChatMessageView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-23.
//

import SwiftUI

struct ChatMessageView: View {
	let message: ChatMessage
	
	var body: some View {
		contentView()
	}
	
	@ViewBuilder
	func contentView() -> some View {
		VStack(alignment: message.style == .incoming ? .leading :.trailing) {
			switch message.content {
			case .text:
				textView(content: message.content)
			case .imageWithCaption, .videoWithCaption:
				EmptyView()
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
			Text(text ?? "Message Could not decrypted")
				.font(Font.app.subTitle)
				.foregroundColor(foregroundColor)
				.padding()
				.background(
					CustomRoundedRectangle(cornerRadius: 30, corners: corners)
						.fill(color)
				)
		}
	}
}

struct ChatMessageView_Previews: PreviewProvider {
	static var previews: some View {
		ChatMessageView(message: ChatMessage.noop1)
	}
}
