//
//  ChatVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-20.
//

import Foundation

extension ChatView {
	@MainActor class ViewModel: ObservableObject {
		@Published var tribe: Tribe
		
		init(tribe: Tribe) {
			self.tribe = tribe
		}
	}
}
