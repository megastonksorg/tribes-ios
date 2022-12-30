//
//  CameraView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-29.
//

import Combine
import SwiftUI

struct CameraView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: CameraView.ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		Group {
			if let image = viewModel.previewImage {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fill)
					.ignoresSafeArea()
			} else {
				Color.red
			}
		}
		.overlay(
			Button(action: { print("TAPPED") }, label: { Text("Tap Me") })
		)
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		CameraView(viewModel: .init())
	}
}
