//
//  TribeInviteVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-24.
//

import Foundation

extension TribeInviteView {
	@MainActor class ViewModel: ObservableObject {
		var tribe: Tribe
		
		@Published var code: Int = 123456
		
		init(tribe: Tribe) {
			self.tribe = tribe
		}
	}
}
