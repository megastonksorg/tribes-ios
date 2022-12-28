//
//  PermissionClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-28.
//

import AVFoundation
import Foundation

@frozen enum PermissionState {
	case undetermined, allowed, denied
}

protocol PermissionClientProtocol {
	//Recording Permission
	func checkRecordPermission() -> PermissionState
	func requestRecordPermission() async -> PermissionState
	
	//Camera Permission
	func checkCameraPermission() -> PermissionState
	func requestCameraPermission() async -> PermissionState
}

class PermissionClient: PermissionClientProtocol {
	static var shared = PermissionClient()
	
	func checkRecordPermission() -> PermissionState {
		switch AVAudioSession.sharedInstance().recordPermission {
		case .undetermined: return .undetermined
		case .denied: return .denied
		case .granted: return .allowed
		@unknown default: return .undetermined
		}
	}
	
	func requestRecordPermission() async -> PermissionState {
		await withCheckedContinuation { continuation in
			AVAudioSession.sharedInstance().requestRecordPermission { granted in
				continuation.resume(returning: granted ? .allowed : .denied)
			}
		}
	}
	
	func checkCameraPermission() -> PermissionState {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized: return .allowed
		case .denied, .restricted: return .denied
		case .notDetermined: return .undetermined
		@unknown default: return .undetermined
		}
	}
	
	func requestCameraPermission() async -> PermissionState {
		let permissionGranted = await AVCaptureDevice.requestAccess(for: .video)
		return permissionGranted ? .allowed : .denied
	}
}
