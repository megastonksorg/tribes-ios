//
//  TribesVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-01-15.
//

import Foundation
import IdentifiedCollections
import SwiftUI

extension TribesView {
	@MainActor class ViewModel: ObservableObject {
		
		@Published var tribeInviteVM: TribeInviteView.ViewModel?
		@Published var tribes: IdentifiedArrayOf<Tribe>
		@Published var user: User
		
		init(tribes: IdentifiedArrayOf<Tribe> = [], user: User) {
			self.tribes = tribes
			self.user = user
		}
		
		func createTribe() {
			AppRouter.pushStack(stack: .home(.createTribe))
		}
		
		func joinTribe() {
			AppRouter.pushStack(stack: .home(.joinTribe))
		}
		
		func openTribeInvite() {
			self.tribeInviteVM = TribeInviteView.ViewModel(tribe: Tribe.noop)
		}
		
		func closeTribeInvite() {
			self.tribeInviteVM = nil
		}
	}
}
