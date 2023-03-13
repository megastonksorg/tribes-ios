//
//  SoundClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-13.
//

import AVKit
import Foundation

class SoundClient {
	enum Sound: String {
		case inAppNotification
		case pushNotification
		case messageSent
	}
	
	static let shared: SoundClient = SoundClient()
	
	var player: AVAudioPlayer? = nil
	
	func playSound(_ sound: Sound) {
		guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
		self.player = try? AVAudioPlayer(contentsOf: url)
		self.player?.play()
	}
}
