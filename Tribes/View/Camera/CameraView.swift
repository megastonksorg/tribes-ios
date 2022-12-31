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
			} else {
				Color.gray
					.blur(radius: 60)
					.overlay(isShown: viewModel.cameraMode == .none) {
						VStack {
							Text("Camera Paused")
								.foregroundColor(.white)
							Button(action: {}) {
								Text("Resume")
									.font(.callout)
									.foregroundColor(.white)
									.padding(6)
									.padding(.horizontal, 2)
									.background(.ultraThinMaterial)
									.cornerRadius(10, corners: .allCorners)
							}
						}
					}
			}
		}
		.onAppear { viewModel.captureClient.startCaptureSession() }
		.onDisappear { viewModel.captureClient.stopCaptureSession() }
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		CameraView(viewModel: .init())
	}
}
