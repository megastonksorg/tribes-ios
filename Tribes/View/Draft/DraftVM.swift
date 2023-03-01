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
		@Published var teaVM: TeaView.ViewModel?
		
		func setTeaContent(content: TeaContent) {
			self.teaVM = TeaView.ViewModel(content: content)
		}
		
		func resetTeaContent() {
			self.teaVM = nil
		}
	}
}
