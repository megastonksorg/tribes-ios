//
//  DraftVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import Foundation
import UIKit

extension DraftView {
	@MainActor class ViewModel: ObservableObject {
		@Published var contentVM: ContentView.ViewModel?
		
		func setContent(image: UIImage) {
			self.contentVM = ContentView.ViewModel(image: image)
		}
	}
}
