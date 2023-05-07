//
//  TribeProfileVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-07.
//

import Combine
import Foundation

extension TribeProfileView {
	@MainActor class ViewModel: ObservableObject {
		enum Stack: Hashable {
			case userProfile
		}
		
		let tribe: Tribe
		
		private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
		
		@Published var stack: [Stack] = []
		@Published var banner: BannerData?
		
		init(tribe: Tribe) {
			self.tribe = tribe
		}
	}
}
