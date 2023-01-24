//
//  CreateTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-23.
//

import Foundation

extension CreateTribeView {
	@MainActor class ViewModel: ObservableObject {
		
		enum Field: Hashable {
			case name
		}
		
		@Published var name: String = ""
		
		var isCreateButtonEnabled: Bool {
			!name.isEmpty
		}
	}
}