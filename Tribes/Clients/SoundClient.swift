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
	
	private var player: AVAudioPlayer? = nil
	
	func playSound(_ sound: Sound) {
		guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
		try? AVAudioSession.sharedInstance()
			.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP, .defaultToSpeaker])
		try? AVAudioSession.sharedInstance()
			.setActive(true)
		self.player = try? AVAudioPlayer(contentsOf: url)
		self.player?.play()
	}
}
