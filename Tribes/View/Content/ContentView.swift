//
//  ContentView.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-30.
//

import SwiftUI

struct ContentView: View {
	
	@StateObject var viewModel: ViewModel
	
	init(viewModel: ContentView.ViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		GeometryReader { proxy in
			Image(uiImage: viewModel.image)
				.resizable()
				.scaledToFill()
				.ignoresSafeArea()
				.frame(size: proxy.size)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(viewModel: .init(image: UIImage()))
	}
}
