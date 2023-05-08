//
//  TribeMemberView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-07.
//

import SwiftUI

struct TribeMemberView: View {
	@StateObject var viewModel: TribeMemberView.ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		Text("Hello, World!")
	}
}

struct TribeMemberView_Previews: PreviewProvider {
	static var previews: some View {
		TribeMemberView(viewModel: .init())
	}
}
