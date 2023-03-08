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
	}
}

struct TeaView_Previews: PreviewProvider {
	static var previews: some View {
		TeaView(viewModel: .init(tribe: Tribe.noop1))
	}
}
