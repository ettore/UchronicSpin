//
//  OAuthService.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation
import CryptoKit


protocol DataFetching: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: DataFetching {}


// MARK: -


protocol OAuthAPI: Sendable {
    var verifierParam: String { get }
    func getToken(requestToken: String?,
                  requestTokenSecret: String?,
                  verifier: String?) async throws -> (token: String,
                                                      secret: String)
    func getAuthorizationURL(token: String) -> URL?
}

extension OAuthAPI {
    func getRequestToken() async throws -> (token: String, secret: String) {
        return try await getToken(requestToken: nil,
                                  requestTokenSecret: nil,
                                  verifier: nil)
    }

    func getAccessToken(requestToken: String,
                        requestTokenSecret: String,
                        verifier: String) async throws -> (token: String,
                                                           secret: String) {
        return try await getToken(requestToken: requestToken,
                                  requestTokenSecret: requestTokenSecret,
                                  verifier: verifier)
    }
}


// MARK: -


actor OAuthService: OAuthAPI {
    let verifierParam: String = "oauth_verifier"
    private let consumerKey: String
    private let consumerSecret: String
    private let baseURL: String
    private let urlSession: DataFetching

    init(consumerKey: String = CONSUMER_KEY,
         consumerSecret: String = CONSUMER_SECRET,
         baseURL: String = "https://api.discogs.com",
         urlSession: DataFetching = URLSession.shared) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    nonisolated func getAuthorizationURL(token: String) -> URL? {
        URL(string: "https://discogs.com/oauth/authorize?oauth_token=\(token)")
    }

    /// Fetches the access token from Discogs if `requestToken`, `tokenSecret`
    /// and `verifier` are present, otherwise fetches request token.
    func getToken(requestToken: String? = nil,
                  requestTokenSecret: String? = nil,
                  verifier: String? = nil) async throws -> (token: String,
                                                            secret: String) {
        var parameters: [String: String] = [
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_signature_method": "PLAINTEXT",
            "oauth_timestamp": generateTimestamp()
        ]

        let url: String
        let isFetchingAccessToken: Bool
        if let requestToken = requestToken,
           let requestTokenSecret = requestTokenSecret,
           let verifier = verifier
        {
            isFetchingAccessToken = true
            parameters["oauth_token"] = requestToken
            parameters["oauth_signature"] = "\(consumerSecret)&\(requestTokenSecret)"
            parameters[verifierParam] = verifier
            url = "\(baseURL)/oauth/access_token"
        } else {
            isFetchingAccessToken = false
            parameters["oauth_signature"] = "\(consumerSecret)&"
            parameters["oauth_callback"] = "uchronicspin://oauth-callback"
            url = "\(baseURL)/oauth/request_token"
        }

        // format params
        let authHeader = parameters
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\"\($0.value)\"" }
            .joined(separator: ", ")

        // create request
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = (isFetchingAccessToken ? "POST" : "GET")
        request.setValue("OAuth \(authHeader)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("uchronicspin", forHTTPHeaderField: "User-Agent")

        // submit request
        let (data, _) = try await urlSession.data(for: request)

        // parse response
        let response = String(data: data, encoding: .utf8)

        // sanity checks
        guard let response = response, response.contains("=") else {
            if isFetchingAccessToken {
                throw AuthError.invalidAccessToken
            } else {
                throw AuthError.invalidRequestToken
            }
        }

        // splits URL-encoded response string such as "key1=val1&key2=val2"
        // into a dictionary
        let params = Dictionary(
            uniqueKeysWithValues: response
                .components(separatedBy: "&")
                .compactMap { $0.components(separatedBy: "=") }
                .compactMap { ($0[0], $0[1]) }
        )

        guard
            let token = params["oauth_token"],
            let secret = params["oauth_token_secret"],
            !token.isEmpty, !secret.isEmpty
        else {
            if isFetchingAccessToken {
                throw AuthError.invalidAccessToken
            } else {
                throw AuthError.invalidRequestToken
            }
        }

        return (token, secret)
    }

    private func generateNonce() -> String {
        let uuid = UUID().uuidString
        return uuid.replacingOccurrences(of: "-", with: "")
    }

    private func generateTimestamp() -> String {
        return String(Int(Date().timeIntervalSince1970))
    }
}
