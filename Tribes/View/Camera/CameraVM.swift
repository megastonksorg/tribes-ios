//
//  CameraVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-29.
//

import Combine
import Foundation
import SwiftUI

extension CameraView {
	@MainActor class ViewModel: ObservableObject {
		
		let captureClient: CaptureClient = CaptureClient()
		var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var previewImage: UIImage?
		
		init() {
			captureClient.captureValuePublisher
				.receive(on: DispatchQueue.main)
				.sink(receiveValue: { captureValue in
					switch captureValue {
					case .image: return
					case .previewImageBuffer(let sampleBuffer):
						guard let image = sampleBuffer?.image() else { return }
						self.previewImage = image
					}
				})
				.store(in: &cancellables)
		}
	}
}
