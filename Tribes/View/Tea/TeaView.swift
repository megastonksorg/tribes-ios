//
//  TeaView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct TeaView: View {
	
	@StateObject var viewModel: ViewModel
	
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
				header()
				Spacer()
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
