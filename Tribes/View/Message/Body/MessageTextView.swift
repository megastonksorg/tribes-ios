//
//  MessageTextView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-05.
//

import SwiftUI

struct MessageTextView: View {
	let model: MessageBodyModel
	@State var isShowingTimeStamp: Bool = false
	
	init(model: MessageBodyModel) {
		self.model = model
	}
	
	var body: some View {
		let avatarSize: CGFloat = 38
		let isIncoming: Bool = model.style == .incoming
		let dummyTribeMember: TribeMember = TribeMember.dummyTribeMember
		HStack(alignment: .top, spacing: 0) {
			Group {
				if let sender = self.model.sender {
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
			if model.style == .outgoing {
				Spacer(minLength: 0)
			}
			Button(action: {
				withAnimation(.easeInOut) {
					self.isShowingTimeStamp = true
				}
				DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
					withAnimation(.easeInOut) {
						self.isShowingTimeStamp = false
					}
				}
			}) {
				VStack(alignment: .leading, spacing: 0) {
					ZStack(alignment: .leading) {
						if isShowingTimeStamp {
							Text(model.message.timeStamp.timeAgoDisplay())
						}
						if isIncoming && !isShowingTimeStamp {
							Text(isIncoming ? model.sender?.fullName ?? dummyTribeMember.fullName : "")
						}
					}
					.lineLimit(1)
					.font(Font.app.callout)
					.foregroundColor(Color.gray)
					contentView()
						.padding(.top, model.style == .outgoing ? 4.0 : 0.0)
				}
			}
			.buttonStyle(.insideScaling)
			if model.style == .incoming {
				Spacer(minLength: 0)
			}
		}
	}
	
	@ViewBuilder
	func contentView() -> some View {
		Group {
			if case .text(let text) = model.message.body?.content {
				textView(text: text, isEncrypted: false)
			} else {
				textView(text: "Message is Encrypted. It could not be decrypted. You were not a member of the Tribe when it was sent or your keys were reset after login.", isEncrypted: true)
					.overlay (
						Image(systemName: AppConstants.encryptedIcon)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.app.secondary, Color.white)
							.font(.system(size: 30))
							.dropShadow()
							.dropShadow()
					)
			}
		}
	}
	
	@ViewBuilder
	func textView(text: String, isEncrypted: Bool) -> some View {
		TextContentView(content: text, style: model.style, isEncrypted: isEncrypted)
	}
}

struct MessageTextView_Previews: PreviewProvider {
	static var previews: some View {
		MessageTextView(
			model: MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				sender: nil,
				style: .incoming,
				message: Message.noopEncryptedTextChat
			)
		)
	}
}
