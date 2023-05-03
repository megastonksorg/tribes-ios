//
//  TeaPotView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-03.
//

import SwiftUI

struct TeaPotView: View {
	@StateObject var viewModel: TeaView.ViewModel
	
	var body: some View {
		VStack {
			ScrollView {
				
			}
		}
		.background(Color.app.background)
		.safeAreaInset(edge: .top) {
			VStack {
				ChatHeaderView(context: .teaPot, members: viewModel.tribe.members)
				TextView(viewModel.tribe.name, style: .tribeName(20, false))
					.padding(.bottom, 6)
			}
			.frame(maxWidth: .infinity)
			.background {
				ZStack {
					Rectangle()
						.fill(.ultraThinMaterial)
					Rectangle()
						.fill(Color.app.background.opacity(0.6))
				}
				.edgesIgnoringSafeArea(.top)
			}
		}
	}
}

struct TeaPotView_Previews: PreviewProvider {
	static var previews: some View {
		TeaPotView(viewModel: .init(tribe: Tribe.noop2))
	}
}
