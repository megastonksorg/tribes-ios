//
//  MessageBodyModel.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-06.
//

import Foundation

struct MessageBodyModel {
	let currentTribeMember: TribeMember
	let sender: TribeMember?
	let style: Message.Style
	let message: Message
}
