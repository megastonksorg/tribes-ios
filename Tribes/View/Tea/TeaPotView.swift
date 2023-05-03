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
			
		}
	}
}

struct TeaPotView_Previews: PreviewProvider {
	static var previews: some View {
		TeaPotView(viewModel: .init(tribe: Tribe.noop2))
	}
}
