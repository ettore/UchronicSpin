//
//  OAuthService.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation
import CryptoKit

protocol OAuthAPI: Sendable {
    var verifierParam: String { get }
    func getRequestToken() async throws -> (token: String, secret: String)
    func getAccessToken(requestToken: String,
                        requestTokenSecret: String,
                        verifier: String) async throws -> (token: String,
                                                           secret: String)
}


/*
 - An actor automatically serializes all access to its properties and methods,
 which ensures that only one caller can directly interact with the actor at any
 given time. That in turn gives us complete protection against data races,
 since all mutations will be performed serially, one after the other.
 - Race conditions are still possible. While data races are essentially
 memory corruption issues, race conditions are logical issues that occur
 when multiple operations end up happening in an unpredictable order.

 Actors are a great tool to allow safe concurrent access to its underlying state.
 However it will require us to interact with it in an asynchronous manner,
 which usually does make such calls somewhat more complex (and slower) to
 perform 
 */
actor OAuthService: OAuthAPI {
    let verifierParam: String = "oauth_verifier"
    private let consumerKey = CONSUMER_KEY
    private let consumerSecret = CONSUMER_SECRET
    private let baseURL = "https://api.discogs.com"
    private var requestToken: String?
    private var requestTokenSecret: String?

    private func generateNonce() -> String {
        let uuid = UUID().uuidString
        return uuid.replacingOccurrences(of: "-", with: "")
    }

    private func generateTimestamp() -> String {
        return String(Int(Date().timeIntervalSince1970))
    }

    private func generateSignature(method: String, url: String, parameters: [String: String], tokenSecret: String = "") -> String {
        let sortedParams = parameters.sorted { $0.key < $1.key }
        let paramString = sortedParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")

        let signatureBase = [
            method,
            url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "",
            paramString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        ].joined(separator: "&")

        let signingKey = "\(consumerSecret)&\(tokenSecret)"
        let signature = HMAC<Insecure.SHA1>.authenticationCode(
            for: Data(signatureBase.utf8),
            using: SymmetricKey(data: Data(signingKey.utf8))
        )

        return Data(signature).base64EncodedString()
    }

    func getRequestToken() async throws -> (token: String, secret: String) {
        var parameters = [
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_signature_method": "PLAINTEXT",
            "oauth_timestamp": generateTimestamp(),
            "oauth_callback": "uchronicspin://oauth-callback"
        ]

        let url = "\(baseURL)/oauth/request_token"
        parameters["oauth_signature"] = "\(consumerSecret)&"

        let authHeader = parameters
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\"\($0.value)\"" }
            .joined(separator: ", ")

        var request = URLRequest(url: URL(string: url)!)
        request.setValue("OAuth \(authHeader)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("uchronicspin", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let response = String(data: data, encoding: .utf8) else {
            throw AuthError.invalidRequestToken
        }

        let params = Dictionary(
            uniqueKeysWithValues: response
                .components(separatedBy: "&")
                .map { $0.components(separatedBy: "=") }
                .map { ($0[0], $0[1]) }
        )

        guard let token = params["oauth_token"],
              let secret = params["oauth_token_secret"] else {
            throw AuthError.invalidRequestToken
        }

        return (token, secret)
    }

    func getAccessToken(requestToken: String,
                        requestTokenSecret: String,
                        verifier: String) async throws -> (token: String,
                                                           secret: String) {
        let parameters = [
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_token": requestToken,
            "oauth_signature": "\(consumerSecret)&\(requestTokenSecret)",
            "oauth_signature_method": "PLAINTEXT",
            "oauth_timestamp": generateTimestamp(),
            "oauth_verifier": verifier
        ]
        let url = "\(baseURL)/oauth/access_token"

        let authHeader = parameters
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\"\($0.value)\"" }
            .joined(separator: ", ")

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("OAuth \(authHeader)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("uchronicspin", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = String(data: data, encoding: .utf8)

        guard
            let response = response,
            response.contains("oauth_token="),
            response.contains("oauth_token_secret=")
        else {
            throw AuthError.invalidAccessToken
        }

        let params = Dictionary(
            uniqueKeysWithValues: response
                .components(separatedBy: "&")
                .map { $0.components(separatedBy: "=") }
                .map { ($0[0], $0[1]) }
        )

        guard
            let token = params["oauth_token"],
            let secret = params["oauth_token_secret"],
            !token.isEmpty, !secret.isEmpty
        else {
            throw AuthError.invalidAccessToken
        }

        return (token, secret)
    }
}
