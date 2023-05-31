//
//  NoteComposeVM.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-31.
//

import Foundation

extension NoteComposeView {
	@MainActor class ViewModel: ObservableObject {
		@Published var backgroundStyle: NoteBackgroundView.Style = NoteBackgroundView.Style.allCases.randomElement() ?? .green
	}
}
