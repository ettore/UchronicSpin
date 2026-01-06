//
//  APIError.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/24/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation

// TODO: reimplement with protocols/structs instead of enums to avoid
//       breaking SOLID Open/Closed principle
enum APIError: LocalizedError {
    case invalidResponse(String)
    case decodingError(Error)
    case httpError(statusCode: Int, message: String?)
    case invalidURL
}

extension APIError: FriendlyError {
    var description: String {
        switch self {
        case .invalidResponse(let endpoint):
            return "Invalid response for endpoint: \(endpoint)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .httpError(let statusCode, let message):
            if let message = message {
                return "HTTP \(statusCode): \(message)"
            }
            return "HTTP error: \(statusCode)"
        case .invalidURL:
            return "Invalid URL"
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case .invalidResponse(let endpoint):
            return "Discogs sent an invalid response when requesting \(endpoint). Please try again later."
        case .decodingError(let error):
            return "An error occurred while trying to decode the data sent back by Discogs: \(error.localizedDescription).\n\nPlease try again later."
        case .httpError(let statusCode, let message):
            if let message = message {
                return "An error occurred while communicating with Discogs: [HTTP \(statusCode): \(message)].\n\nPlease try again later."
            }
            return "An error occurred while communicating with Discogs: [HTTP \(statusCode)].\n\nPlease try again later."
        case .invalidURL:
            return "It was attempted to reach Discogs with an invalid URL. Please contact us with details of how this happened."
        }
    }
}
