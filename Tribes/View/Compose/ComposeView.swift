//
//  ComposeView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct ComposeView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		if viewModel.hasContentBeenCaptured {
			DraftView(viewModel: viewModel.draftVM)
				.onAppear {
					if viewModel.allowedRecipients.count == 0 {
						viewModel.fetchAllowedTeaRecipients()
					}
				}
		} else {
			CameraView(viewModel: viewModel.cameraVM)
				.onAppear { viewModel.fetchAllowedTeaRecipients() }
		}
	}
}

struct ComposeView_Previews: PreviewProvider {
	static var previews: some View {
		ComposeView(viewModel: .init())
	}
}
