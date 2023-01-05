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
	
	@GestureState var isShutterButtonPressed = false
	
	init(viewModel: CameraView.ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		GeometryReader { proxy in
			Group {
				if let image = viewModel.previewImage {
					Image(uiImage: image)
						.resizable()
						.scaledToFill()
				} else {
					Color.black
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
			.frame(size: proxy.size)
		}
		.ignoresSafeArea()
		.overlay {
			VStack {
				HStack {
					Button(action: { viewModel.toggleFlash() }) {
						Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
							.font(.title)
							.foregroundColor(.white)
							.padding(.leading, 20)
					}
					
					Spacer()
				}
				
				Spacer()
				
				captureButton()
					.gesture(
						DragGesture(minimumDistance: 0)
							.updating($isShutterButtonPressed) { _, isShutterButtonPressed, _ in
								isShutterButtonPressed = true
							}
							.onChanged { value in
								//Update Zoom factor
							}
					)
					.onChange(of: isShutterButtonPressed) { _ in
						if isShutterButtonPressed {
							viewModel.didPressShutter()
						} else {
							viewModel.didReleaseShutter()
						}
					}
			}
			.background(
				Color.clear
					.contentShape(Rectangle())
					.onTapGesture(count: 2, perform: { viewModel.captureClient.toggleCamera() })
			)
		}
		.onAppear { viewModel.didAppear() }
		.onDisappear { viewModel.didDisappear() }
	}
	
	@ViewBuilder
	func captureButton() -> some View {
		ZStack {
			Circle()
				.fill(Color.white)
				.frame(dimension: 75)
			Circle()
				.fill(Color.white.opacity(0.3))
				.frame(dimension: 85)
		}
		.opacity(isShutterButtonPressed ? 0.5 : 1.0)
		.overlay(isShown: viewModel.isCapturingImage) {
			CaptureLoadingIndicator()
				.frame(dimension: 40)
		}
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		CameraView(viewModel: .init())
	}
}
