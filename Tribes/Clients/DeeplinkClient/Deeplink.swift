//
//  Deeplink.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-20.
//

import Foundation

enum Deeplink {
	case tea(_ tribeId: Tribe.ID)
	case message(_ tribeId: Tribe.ID)
}
