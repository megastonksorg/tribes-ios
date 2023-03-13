//
//  SoundClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-03-13.
//

import AVKit
import Foundation

class SoundClient {
	static let shared: SoundClient = SoundClient()
	
	var player: AVAudioPlayer? = nil
	
	func playSound() {
		guard let url = Bundle.main.url(forResource: "wave", withExtension: ".mp3") else { return }
		self.player = try? AVAudioPlayer(contentsOf: url)
		self.player?.play()
	}
}
