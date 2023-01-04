//
//  AppError.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2022-07-15.
//

import Foundation

enum AppError: Error {
	
	enum APIClientError: Error {
		case invalidURL
		case httpError(statusCode: Int, data: Data)
		case decodingError
		case rawError(String)
		
		var title: String { "API Error" }
	}
	
	enum CaptureClientError: Error {
		case couldNotAddDataConnection
		case couldNotAddPhotoOutput
		case couldNotAddPorts
		case couldNotAddVideoInput
		case couldNotAddVideoOutput
		case failedToGenerateVideoSettings
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
		case .couldNotAddPorts:
			return NSLocalizedString(
				"Ports could not be added to the capture session",
				comment: "Could not add ports"
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
		case .failedToGenerateVideoSettings:
			return NSLocalizedString(
				"Video settings could not be retrieved from the output",
				comment: "Failed To Get Video Settings"
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
					"Could not generate a new wallet",
					comment: "Unable to Generate New Wallet"
				)
			case .couldNotImportWallet:
				return NSLocalizedString(
					"Could not import a valid wallet for the mnemonic",
					comment: "Invalid Mnemonic"
				)
			case .couldNotImportWalletForSigning:
				return NSLocalizedString(
					"Could not import a valid wallet for your existing mnemonic",
					comment: "Invalid Mnemonic"
				)
			case .couldNotVerifyMnemonic:
				return NSLocalizedString(
					"Could not verify the secret phrase you entered. Please try again and remember the order of the words is important",
					comment: "Invalid Mnemonic"
				)
			case .errorSigningMessage:
				return NSLocalizedString(
					"Error encountered while signing message with wallet",
					comment: "Error Signing Message"
				)
			case .errorRetrievingMnemonic:
				return NSLocalizedString(
					"Error encountered while retrieving mnemonic",
					comment: "Error Retrieving Mnemonic"
				)
		}
	}
}
