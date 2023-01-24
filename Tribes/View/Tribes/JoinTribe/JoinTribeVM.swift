//
//  JoinTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import Foundation

extension JoinTribeView {
	@MainActor class ViewModel: ObservableObject {
		
		let codeLimit: Int = 6
		
		@Published var code: String = "123456"
		@Published var isJoinButtonEnabled: Bool = false
	}
}
