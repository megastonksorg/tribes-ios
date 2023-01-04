//
//  TeaContentVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import Foundation
import UIKit

extension TeaContentView {
	@MainActor class ViewModel: ObservableObject {
		var content: TeaContent
		
		init(content: TeaContent) {
			self.content = content
		}
	}
}