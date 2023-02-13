//
//  AccountVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-12.
//

import Foundation

extension AccountView {
	@MainActor class ViewModel: ObservableObject {
		let user: User
		
		init(user: User) {
			self.user = user
		}
	}
}
