//
//  AuthError.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation

enum AuthError: LocalizedError {
    case missingRequestToken
    case invalidRequestToken
    case missingAccessToken
    case invalidAccessToken
    case userCancelled
    case keychainError(KeychainError)
    case networkError(Error)
    case invalidUsername(Int, String?)

    var errorDescription: String? {
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
        }
    }
}
