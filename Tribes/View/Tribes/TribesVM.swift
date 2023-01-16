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
		
		@Published var tribes: IdentifiedArrayOf<Tribe> = []
	}
}
