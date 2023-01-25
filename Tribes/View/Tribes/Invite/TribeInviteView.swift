//
//  TribeInviteView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import SwiftUI

struct TribeInviteView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		Text("Hello, World!")
	}
}

struct TribeInviteView_Previews: PreviewProvider {
	static var previews: some View {
		TribeInviteView(viewModel: .init())
	}
}
