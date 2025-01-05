//
//  AuthError.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidRequestToken
    case invalidAccessToken
    case userCancelled
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidRequestToken:
            return "Failed to obtain request token"
        case .invalidAccessToken:
            return "Failed to obtain access token"
        case .userCancelled:
            return "Authentication was cancelled"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
