//
//  AppError.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-15.
//

import Foundation

enum AppError: Error {
	
	enum APIClientError: Error, Equatable {
		case authExpired
		case invalidURL
		case httpError(statusCode: Int, data: Data)
		case decodingError
		case rawError(String)
		
		var title: String { "API Error" }
	}
	
	enum CaptureClientError: Error {
		case couldNotAddAudioDevice
		case couldNotAddAudioOutput
		case couldNotAddDataConnection
		case couldNotAddPhotoOutput
		case couldNotAddVideoInput
		case couldNotAddVideoOutput
		case couldNotConfigureAudioSession
		case failedToGenerateAudioAndVideoSettings
		case noCaptureDevice
		
		var title: String { "Capture Error" }
	}
	
	enum RecorderError: Error {
		case cancelled
		case failedToGenerateVideo
		case invalidState
	}
	
	enum WalletError: Error {
		case couldNotGenerateWallet
		case couldNotImportWallet
		case couldNotImportWalletForSigning
		case couldNotVerifyMnemonic
		case errorSigningMessage
		case errorRetrievingMnemonic
		
		var title: String { "Wallet Error" }
	}
	
	case apiClientError(APIClientError)
	case captureClientError(CaptureClientError)
	case recorderError(RecorderError)
	case walletError(WalletError)
}

extension AppError.APIClientError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .authExpired:
			return NSLocalizedString(
				"Authentication has expired. You will be logged out now",
				comment: "Auth Expired"
			)
			case .invalidURL:
				return NSLocalizedString(
					"Request URL could not be formed or is Invalid",
					comment: "Invalid Url"
				)
			case let .httpError(statusCode: statusCode, data: data):
				return NSLocalizedString(
					"Error \(statusCode) Processing Request: \(String(decoding: data, as: UTF8.self))",
					comment: "HTTP Error"
				)
			case .decodingError:
				return NSLocalizedString(
					"Error Decoding Object: Please try that again",
					comment: "Decoder Error"
				)
			case .rawError(let error):
				return NSLocalizedString(
					"\(error)",
					comment: "Raw Error"
				)
		}
	}
}

extension AppError.CaptureClientError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .couldNotAddAudioDevice:
			return NSLocalizedString(
				"Audio input device could not be added to the capture session",
				comment: "Could not add audio input"
			)
		case .couldNotAddAudioOutput:
			return NSLocalizedString(
				"Audio output could not be added to the capture session",
				comment: "Could not add output"
			)
		case .couldNotAddDataConnection:
			return NSLocalizedString(
				"Data Connection could not be added to the capture session",
				comment: "Could not add data connection"
			)
		case .couldNotAddPhotoOutput:
			return NSLocalizedString(
				"Photo output could not be added to the capture session",
				comment: "Could not add output"
			)
		case .couldNotAddVideoInput:
			return NSLocalizedString(
				"Video input device could not be added to the capture session",
				comment: "Could not add input"
			)
		case .couldNotAddVideoOutput:
			return NSLocalizedString(
				"Video output could not be added to the capture session",
				comment: "Could not add output"
			)
		case .couldNotConfigureAudioSession:
			return NSLocalizedString(
				"Audio session could not be configured",
				comment: "Could not configure audio"
			)
		case .failedToGenerateAudioAndVideoSettings:
			return NSLocalizedString(
				"Audio and video settings could not be generated from the output",
				comment: "Failed To Generate audio and video Settings"
			)
		case .noCaptureDevice:
			return NSLocalizedString(
				"Could not find a capture device",
				comment: "No Capture Device"
			)
		}
	}
}

extension AppError.RecorderError {
	var errorDescription: String? {
		switch self {
		case .cancelled:
			return NSLocalizedString(
				"Asset writer operation was cancelled",
				comment: "Operation Cancelled"
			)
		case .failedToGenerateVideo:
			return NSLocalizedString(
				"Asset writer failed to generate video file",
				comment: "Failed Video Generation"
			)
		case .invalidState:
			return NSLocalizedString(
				"Asset writer is in an invalid state",
				comment: "Invalid State"
			)
		}
	}
}

extension AppError.WalletError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .couldNotGenerateWallet:
				return NSLocalizedString(
					"Could not generate a new secret key",
					comment: "Unable to Generate New Key"
				)
			case .couldNotImportWallet:
				return NSLocalizedString(
					"Could not import a valid secret key",
					comment: "Invalid Secret Key"
				)
			case .couldNotImportWalletForSigning:
				return NSLocalizedString(
					"Could not import your secret key. Please try again",
					comment: "Invalid Secret Key"
				)
			case .couldNotVerifyMnemonic:
				return NSLocalizedString(
					"Could not verify the secret key you entered. Please try again and remember the order of the words is important",
					comment: "Invalid Secret Key"
				)
			case .errorSigningMessage:
				return NSLocalizedString(
					"Error encountered while signing message with your secret key",
					comment: "Error Signing Message"
				)
			case .errorRetrievingMnemonic:
				return NSLocalizedString(
					"Error encountered while retrieving secret key",
					comment: "Error Retrieving Secret Key"
				)
		}
	}
}
