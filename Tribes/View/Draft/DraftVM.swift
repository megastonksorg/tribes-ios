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
		@Published var teaContentVM: TeaContentView.ViewModel?
		
		func setTeaContent(content: TeaContent) {
			self.teaContentVM = TeaContentView.ViewModel(content: content)
		}
		
		func resetTeaContent() {
			self.teaContentVM = nil
		}
	}
}
