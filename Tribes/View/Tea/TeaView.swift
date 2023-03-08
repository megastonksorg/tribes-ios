//
//  TeaView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct TeaView: View {
	
	@FocusState private var focusedField: ViewModel.FocusField?
	
	@StateObject var viewModel: ViewModel
	
	@ObservedObject var keyboardClient: KeyboardClient = KeyboardClient.shared
	
	init(viewModel: TeaView.ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		GeometryReader { proxy in
			ZStack {
				ForEach(viewModel.tea) { tea in
					MessageView(currentTribeMember: viewModel.currentTribeMember, message: tea, tribe: viewModel.tribe)
				}
			}
			.frame(size: proxy.size)
		}
		.ignoresSafeArea()
		.overlay {
			VStack {
				let yOffset: CGFloat = {
					if keyboardClient.height == 0 {
						return 0
					} else {
						return keyboardClient.height - 25
					}
				}()
				header()
				Button(action: { self.focusedField = nil }) {
					Text("Tap Me")
				}
				Spacer()
				ZStack(alignment: .topLeading) {
					Group {
						Text("Message ")
							.foregroundColor(Color.white)
						+
						Text(viewModel.tribe.name)
							.foregroundColor(Color.app.tertiary)
					}
					.lineLimit(2)
					.opacity(viewModel.canSendText ? 0.0 : 1.0)
					TextField("", text: $viewModel.text, axis: .vertical)
						.tint(Color.white)
						.lineLimit(1...4)
						.foregroundColor(.white)
						.focused($focusedField, equals: .text)
				}
				.font(Font.app.body)
				.multilineTextAlignment(.leading)
				.padding(.horizontal, 12)
				.padding(.vertical, 14)
				.background {
					RoundedRectangle(cornerRadius: 14)
						.stroke(Color.white, lineWidth: 1)
						.transition(.opacity)
				}
				.dropShadow()
				.dropShadow()
				.offset(y: -yOffset)
			}
			.padding(.horizontal)
		}
	}
	
	@ViewBuilder
	func header() -> some View {
		HStack(spacing: 10) {
			HStack(spacing: -12) {
				ForEach(0..<viewModel.tribe.members.count, id: \.self) { index in
					UserAvatar(url: viewModel.tribe.members[index].profilePhoto)
						.frame(dimension: 24)
						.zIndex(-Double(index))
				}
			}
			HStack(spacing: 0) {
				TextView("\(viewModel.tribe.name)  •   ", style: .tribeName(16))
					.multilineTextAlignment(.leading)
					.lineLimit(2)
				Text("2hrs ago")
					.font(Font.app.body)
					.foregroundColor(Color.app.tertiary)
			}
			Spacer()
			XButton {
			}
			.padding([.top, .leading, .bottom])
		}
	}
}

struct TeaView_Previews: PreviewProvider {
	static var previews: some View {
		TeaView(viewModel: .init(tribe: Tribe.noop2))
			.preferredColorScheme(.dark)
	}
}
