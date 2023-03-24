//
//  MessageTextView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-05.
//

import SwiftUI

struct MessageTextView: View {
	let model: MessageBodyModel
	let isShowingIncomingAuthor: Bool
	let contextMessageAction: (_ messageId: Message.ID) -> ()
	
	@State var messageContext: Message?
	@State var didFailToLoadContext: Bool = false
	@State var isShowingTimeStamp: Bool = false
	
	init(
		model: MessageBodyModel,
		isShowingIncomingAuthor: Bool,
		contextMessageAction: @escaping (_ messageId: Message.ID) -> () = { _ in }
	) {
		self.model = model
		self.isShowingIncomingAuthor = isShowingIncomingAuthor || model.message.context != nil
		self._messageContext = State(initialValue: model.message.context)
		self.contextMessageAction = contextMessageAction
	}
	
	var body: some View {
		let isIncoming: Bool = model.style == .incoming
		let dummyTribeMember: TribeMember = TribeMember.dummyTribeMember
		VStack(alignment: .leading, spacing: 0) {
			if let context = self.messageContext {
				HStack(alignment: .bottom) {
					let shapeCornerRadius: CGFloat = 20
					avatar()
						.opacity(0)
						.overlay(
							LShape()
								.stroke(Color.gray, lineWidth: 2)
								.frame(width: 15, height: 20)
								.rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
								.offset(x: 5)
								.opacity(isIncoming ? 0.2 : 0.0)
						)
					if !isIncoming {
						Spacer()
					}
					Group {
						if didFailToLoadContext {
							VStack {
								Image(systemName: "clock.arrow.circlepath")
									.foregroundColor(Color.gray)
								TextView("Expired", style: .hint)
							}
						} else {
							Button(action: { contextMessageAction(context.id) }) {
								MessageView(
									currentTribeMember: model.currentTribeMember,
									message: context,
									tribe: Tribe.noop1,
									isPlaying: false,
									isShowingIncomingAuthor: false
								)
								.scaledToFill()
							}
						}
					}
					.frame(width: 100, height: 140)
					.clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
					.background {
						Color.app.secondary
							.clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
					}
					.opacity(self.didFailToLoadContext ? 0.4 : 1.0)
					.onAppear {
						if let context = self.messageContext {
							if let message = MessageClient.shared.tribesMessages[id: model.tribe.id]?.messages[id: context.id] {
								self.messageContext = message
							} else {
								self.didFailToLoadContext = true
							}
						}
					}
				}
			}
			HStack(alignment: .top, spacing: 0) {
				avatar()
					.opacity(isIncoming && isShowingIncomingAuthor ? 1.0 : 0.0)
				Spacer()
					.frame(width: 10)
				if model.style == .outgoing {
					Spacer(minLength: 0)
				}
				VStack(alignment: .leading, spacing: 0) {
					ZStack {
						if isShowingIncomingAuthor && !isShowingTimeStamp && isIncoming {
							Text(isIncoming ? model.sender?.fullName ?? dummyTribeMember.fullName : "")
						}
						if isShowingTimeStamp {
							Text(model.message.timeStamp.timeAgoDisplay())
						}
					}
					.lineLimit(1)
					.font(Font.app.callout)
					.foregroundColor(Color.gray)
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
						contentView()
							.padding(.top, model.style == .outgoing ? 2.0 : 4.0)
					}
				}
				.buttonStyle(.insideScaling)
				if model.style == .incoming {
					Spacer(minLength: 0)
				}
			}
		}
		.padding(.top, self.messageContext == nil ? 0 : 6 )
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
		TextContentView(
			content: text,
			isEncrypted: isEncrypted,
			shouldRoundAllCorners: !isShowingIncomingAuthor && model.style == .incoming,
			style: model.style
		)
	}
	
	@ViewBuilder
	func avatar() -> some View {
		Group {
			if let sender = self.model.sender {
				UserAvatar(url: sender.profilePhoto)
			} else {
				Circle()
					.fill(Color.gray)
			}
		}
		.frame(dimension: 38)
	}
}

struct MessageTextView_Previews: PreviewProvider {
	static var previews: some View {
		MessageTextView(
			model: MessageBodyModel(
				currentTribeMember: TribeMember.noop1,
				sender: nil,
				style: .outgoing,
				message: Message.noopDecryptedTextWithImageContextChat,
				tribe: Tribe.noop1
			),
			isShowingIncomingAuthor: false
		)
	}
}
