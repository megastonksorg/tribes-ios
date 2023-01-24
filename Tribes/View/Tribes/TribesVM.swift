//
//  TribesVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-15.
//

import Foundation
import IdentifiedCollections

extension TribesView {
	@MainActor class ViewModel: ObservableObject {
		
		enum Stack: Hashable {
			case create
			case join
		}
		
		@Published var navStack: [Stack] = []
		@Published var tribes: IdentifiedArrayOf<Tribe>
		@Published var user: User
		
		init(tribes: IdentifiedArrayOf<Tribe> = [], user: User) {
			self.tribes = tribes
			self.user = user
		}
	}
}
