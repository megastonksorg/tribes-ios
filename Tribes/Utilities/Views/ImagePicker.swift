//
//  ImagePicker.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-13.
//
import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
	@Binding var image: UIImage?

	func makeUIViewController(context: Context) -> PHPickerViewController {
		var config = PHPickerConfiguration()
		config.filter = .any(of: [.images, .livePhotos])
		let picker = PHPickerViewController(configuration: config)
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, PHPickerViewControllerDelegate {
		let parent: ImagePicker

		init(_ parent: ImagePicker) {
			self.parent = parent
		}

		func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
			picker.dismiss(animated: true)

			guard let provider = results.first?.itemProvider else { return }

			if provider.canLoadObject(ofClass: UIImage.self) {
				provider.loadObject(ofClass: UIImage.self) { item, _ in
					if let image = item as? UIImage {
						DispatchQueue.main.async {
							withAnimation(.easeInOut.speed(0.4)) {
								self.parent.image = image
							}
						}
					}
				}
			}
		}
	}
}
