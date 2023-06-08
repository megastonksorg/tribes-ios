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
			guard let provider = results.first?.itemProvider else { return }
			if(provider.hasItemConformingToTypeIdentifier(UTType.image.identifier)) {
				provider.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _, error in
					do {
						if let url = url, let image = UIImage(data: try Data(contentsOf: url)) {
							DispatchQueue.main.async {
								withAnimation(.easeInOut.speed(0.4)) {
									self.parent.image = image
								}
							}
						} else {
							print("Could not load Image")
						}
					} catch {
						print("Could not load Image")
					}
				}
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				picker.dismiss(animated: true)
			}
		}
	}
}
