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
										.font(Font.app.callout)
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
							.font(Font.app.title)
							.foregroundColor(.white)
							.padding(.leading, 20)
					}
					.opacity(viewModel.isRecordingVideo ? 0.0 : 1.0)
					
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
								viewModel.updateZoomFactor(low: value.startLocation.y, high: value.location.y)
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
			.overlay(isShown: viewModel.setUpResult == .configurationFailed) {
				VStack {
					Button(action: { viewModel.initializeCaptureClient() }) {
						Text("Resume")
							.font(Font.app.subTitle)
							.foregroundColor(.white)
							.padding(6)
							.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
					}
				}
				.pushOutFrame()
				.background(Color.gray.opacity(0.8))
			}
			.overlay(isShown: !viewModel.isPermissionAllowed) {
				VStack {
					VStack {
						Spacer()
						let symbolSize: CGFloat = 50
						Text(viewModel.permissionText)
							.font(Font.app.subTitle)
							.multilineTextAlignment(.center)
							.padding(.bottom, 40)
						HStack {
							Image(systemName: "camera")
								.font(Font.app.title)
								.frame(dimension: symbolSize)
							Text("Camera")
								.padding(.leading)
							Spacer()
							Toggle(
								"",
								isOn: Binding(
									get: { return viewModel.cameraPermissionState == .allowed },
									set: { _ in viewModel.requestCameraAccess() }
								)
							)
						}
						
						HStack {
							Image(systemName: "mic")
								.font(Font.app.title)
								.frame(dimension: symbolSize)
							Text("Mic")
								.padding(.leading)
							Spacer()
							Toggle(
								"",
								isOn: Binding(
									get: { return viewModel.audioPermissionState == .allowed },
									set: { _ in viewModel.requestMicrophoneAccess() }
								)
							)
						}
						Spacer()
					}
					.foregroundColor(.white)
					.tint(Color.app.secondary)
					.padding(.horizontal, 40)
				}
				.pushOutFrame()
				.background(Color.app.primary.opacity(0.8))
			}
		}
		.onBecomingVisible { viewModel.didAppear() }
		.onDisappear { viewModel.didDisappear() }
	}
	
	@ViewBuilder
	func captureButton() -> some View {
		let isRecordingVideo = viewModel.videoRecordingProgress > 0.05
		let color: Color = {
			return isRecordingVideo ? Color.app.secondary : Color.white
		}()
		Circle()
			.fill(color.opacity(0.3))
			.overlay(
				Circle()
					.inset(by: 2)
					.trim(from: 0, to: viewModel.videoRecordingProgress)
					.stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
					.animation(.linear, value: viewModel.videoRecordingProgress)
					.rotationEffect(Angle(degrees: -90))
			)
			.frame(dimension: 85)
			.overlay(
				Circle()
					.fill(color.opacity(isRecordingVideo ? 0.5 : 1.0))
					.padding(4)
			)
			.opacity(isShutterButtonPressed && !isRecordingVideo ? 0.5 : 1.0)
			.overlay(isShown: viewModel.isCapturingImage) {
				LoadingIndicator(style: .camera)
					.frame(dimension: SizeConstants.loadingIndicatorSize)
			}
	}
}

struct CameraView_Previews: PreviewProvider {
	static var previews: some View {
		CameraView(viewModel: .init())
	}
}
