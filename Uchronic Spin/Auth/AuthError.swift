//
//  AuthError.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation

enum AuthError: LocalizedError, CustomStringConvertible {
    case missingRequestToken
    case invalidRequestToken
    case missingAccessToken
    case invalidAccessToken
    case userCancelled
    case keychainError(KeychainError)
    case networkError(Error)
    case invalidUsername(Int, String?)
    case persistentStorageError(Error)

    var description: String {
        switch self {
        case .missingRequestToken:
            return "Failed to obtain request token"
        case .invalidRequestToken:
            return "Invalid request token"
        case .missingAccessToken:
            return "Missing access token"
        case .invalidAccessToken:
            return "Failed to obtain access token"
        case .userCancelled:
            return "Authentication was cancelled"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .keychainError(let keychainError):
            return "Keychain error: \(keychainError.localizedDescription)"
        case .invalidUsername(let statusCode, let msg):
            return "Failed to fetch username [HTTP: \(statusCode) \(msg ?? "")"
        case .persistentStorageError(let error):
            return "Persistent storage error: \(error.localizedDescription)"
        }
    }
}

extension AuthError: FriendlyError {
    var userFriendlyMessage: String {
        switch self {
        case .missingRequestToken:
            fallthrough
        case .invalidRequestToken:
            fallthrough
        case .missingAccessToken:
            fallthrough
        case .invalidAccessToken:
            return "An error occurred while authenticating with your Discogs account. Please try again later."
        case .userCancelled:
            return "Authentication cancelled"
        case .networkError(let error):
            return "An error occurred while communicating with Discogs: [\(error.localizedDescription)].\n\nPlease try again later."
        case .keychainError(let keychainError):
            return "An error occurred saving your credentials to your device's keychain: [\(keychainError.localizedDescription)].\n\nPlease try signing out and signing in again."
        case .invalidUsername(let statusCode, let msg):
            return "An error occurred after obtaining your username from Discogs: [HTTP \(statusCode) \(msg ?? "")].\n\nPlease try again later."
        case .persistentStorageError(let error):
            return "An error occurred while storing your Discogs user's information on your device: [\(error.localizedDescription)]\n\nPlease try again later."
        }
    }
}
