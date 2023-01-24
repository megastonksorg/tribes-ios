//
//  JoinTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import Foundation

extension JoinTribeView {
	@MainActor class ViewModel: ObservableObject {
		
		@Published var code: String = ""
	}
}
