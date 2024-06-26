//
//  Gradients.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-05-15.
//

import SwiftUI

extension LinearGradient {
	static let background = LinearGradient(colors: [.app.primary, .app.secondary, .black, .black], startPoint: .top, endPoint: .bottom)
	
	static let camera = LinearGradient(colors: [.white, .app.camera.opacity(0.37)], startPoint: .topLeading, endPoint: .bottomTrailing)
	
	static let dropShadow = LinearGradient(colors: [.clear, .black.opacity(0.2), .black.opacity(0.2), .black.opacity(0.2)], startPoint: .top, endPoint: .bottom)
	
	static let black = LinearGradient(colors: [.black, .black.opacity(0.2), .black.opacity(0.2), .black.opacity(0.2)], startPoint: .top, endPoint: .bottom)
	
	static let green = LinearGradient(colors: [.app.secondary.opacity(0.8), .app.secondary], startPoint: .leading, endPoint: .trailing)
	
	static let red = LinearGradient(colors: [.app.red.opacity(0.8), .app.red], startPoint: .leading, endPoint: .trailing)
	
	static let shine = LinearGradient(colors: [.white.opacity(0.5), .white], startPoint: .leading, endPoint: .trailing)
	
	static let gray = LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
	
	static let white = LinearGradient(colors: [.white], startPoint: .leading, endPoint: .trailing)
	
	static let clear = LinearGradient(colors: [], startPoint: .center, endPoint: .center)
}
