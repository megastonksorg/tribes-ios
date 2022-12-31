//
//  ContentVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import Foundation
import UIKit

extension ContentView {
	@MainActor class ViewModel: ObservableObject {
		var image: UIImage
		
		init(image: UIImage) {
			self.image = image
		}
	}
}
