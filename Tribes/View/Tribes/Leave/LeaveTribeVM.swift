//
//  LeaveTribeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-02-02.
//

import Foundation

extension LeaveTribeView {
	@MainActor class ViewModel: ObservableObject {
		enum FocusField: Hashable {
		  case field
		}
		
		let tribe: Tribe
		
		@Published var isLoading: Bool = false
		@Published var banner: BannerData?
		
		init(tribe: Tribe) {
			self.tribe = tribe
		}
	}
}
