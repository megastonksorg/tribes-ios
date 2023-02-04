//
//  CachedImage.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-03.
//

import SwiftUI

struct CachedImage: View {
	let url: URL
	
	@State var image: UIImage?
	
	var body: some View {
		Group {
			if let uiImage = image {
				Image(uiImage: uiImage)
			} else {
				Color.gray.opacity(0.2)
			}
		}
		.task(id: url) {
			loadImage()
		}
		.onChange(of: url) { _ in
			image = nil
		}
		.onAppear {
			loadImage()
		}
	}
	
	func loadImage() {
		Task {
			guard image == nil else { return }
			image = await APIClient.shared.getImage(url: url)
		}
	}
}

struct CachedImage_Previews: PreviewProvider {
	static var previews: some View {
		CachedImage(url: URL(string: "https://kingsleyokeke.blob.core.windows.net/images/1597276037537.jpeg")!)
	}
}
