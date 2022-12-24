//
//  MnemonicWord.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-06-28.
//

import Foundation
import IdentifiedCollections

struct MnemonicWord: Identifiable {
	let id: UUID = UUID()
	var text: String
	var isSelected: Bool = false
	let isSelectable: Bool
	let isAlternateStyle: Bool
}

extension MnemonicWord {
	var isEmpty: Bool { text.isEmpty }
}

struct MnemonicPhrase {
	static var preview: IdentifiedArrayOf<MnemonicWord> = {
		[
			MnemonicWord(text: "boy", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "girl", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "shoe", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "can", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "baby", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "geez", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "bad", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "rain", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "trouble", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "uncanny", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "journey", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "look", isSelectable: true, isAlternateStyle: false),
		]
	}()
	
	static var previewAlternateStyle: IdentifiedArrayOf<MnemonicWord> = {
		[
			MnemonicWord(text: "boy", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "girl", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "shoe", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "can", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "baby", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "geez", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "bad", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "rain", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "trouble", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "uncanny", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "journey", isSelectable: true, isAlternateStyle: true),
			MnemonicWord(text: "look", isSelectable: true, isAlternateStyle: true),
		]
	}()
}

extension MnemonicPhrase {
	static var empty: IdentifiedArrayOf<MnemonicWord> = {
		[
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
			MnemonicWord(text: "", isSelectable: true, isAlternateStyle: false),
		]
	}()
}
