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
		  case confirmation
		}
		
		static let confirmationTitle: String = "Leave"
		let tribe: Tribe
		
		var isConfirmed: Bool {
			confirmation == ViewModel.confirmationTitle
		}
		
		@Published var confirmation: String = ""
		@Published var isLoading: Bool = false
		@Published var banner: BannerData?
		
		init(tribe: Tribe) {
			self.tribe = tribe
		}
	}
}
