//
//  TribesRepositoryListener.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-11.
//

import Foundation
import IdentifiedCollections

final class TribesRepositoryListener: TribesRepositoryDelegate {
	var repositoryUpdated: @MainActor (IdentifiedArrayOf<Tribe>) -> Void
	
	init() {
		self.repositoryUpdated = { _ in }
	}
	
	func tribesUpdated(_ tribes: IdentifiedArrayOf<Tribe>) {
		Task {
			await repositoryUpdated(tribes)
		}
	}
}
