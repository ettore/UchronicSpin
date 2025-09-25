//
//  APIError.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/24/25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidResponse(String)
    case decodingError(Error)
    case httpError(statusCode: Int, message: String?)
    case invalidURL

    var errorDescription: String? {
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
}
