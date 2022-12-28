//
//  PermissionClient.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-12-28.
//

import AVFoundation
import Foundation

struct PermissionClient {
	@frozen enum PermissionState {
		case undetermined, allowed, denied
	}
	
	//Recording Permission
	var checkRecordPermission: () -> PermissionState
	var requestRecordPermission: () async -> PermissionState
	
	//Camera Permission
	var checkCameraPermission: () -> PermissionState
	var requestCameraPermission: () async -> PermissionState
}

extension PermissionClient {
	static var live: PermissionClient {
		PermissionClient(
			checkRecordPermission: {
				switch AVAudioSession.sharedInstance().recordPermission {
				case .undetermined: return .undetermined
				case .denied: return .denied
				case .granted: return .allowed
				@unknown default: return .undetermined
				}
			},
			requestRecordPermission: {
				await withCheckedContinuation { continuation in
					AVAudioSession.sharedInstance().requestRecordPermission { granted in
						continuation.resume(returning: granted ? .allowed : .denied)
					}
				}
			},
			checkCameraPermission: {
				switch AVCaptureDevice.authorizationStatus(for: .video) {
				case .authorized: return .allowed
				case .denied, .restricted: return .denied
				case .notDetermined: return .undetermined
				@unknown default: return .undetermined
				}
			},
			requestCameraPermission: {
				let permissionGranted = await AVCaptureDevice.requestAccess(for: .video)
				return permissionGranted ? .allowed : .denied
			}
		)
	}
}
