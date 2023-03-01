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
		@Published var content: Message.Content?
		
		func setContent(content: Message.Content) {
			self.content = content
		}
		
		func resetContent() {
			self.content = nil
		}
	}
}
