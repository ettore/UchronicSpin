//
//  OAuthService.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation
import CryptoKit


/// The whole she-bang.
protocol API: OAuthAPI, CollectionAPI {}


// MARK: -


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
    func setAccessCredentials(token: String?, secret: String?) async
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


/// The main API service.
///
/// The main class only covers authentication and common utilities.
/// Actual APIs such as collection etc are available in extensions.
actor APIService: OAuthAPI {
    let verifierParam: String = "oauth_verifier"
    private let consumerKey: String
    private let consumerSecret: String
    private let userAgent: String
    let baseURL: String
    let urlSession: DataFetching
    private(set) var accessToken: String?
    private(set) var accessTokenSecret: String?
    private(set) var username: String?

    init(consumerKey: String = CONSUMER_KEY,
         consumerSecret: String = CONSUMER_SECRET,
         userAgent: String = USER_AGENT,
         baseURL: String = "https://api.discogs.com",
         urlSession: DataFetching = URLSession.shared) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.userAgent = userAgent
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    // MARK: - Authentication API

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
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

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

        accessToken = token
        accessTokenSecret = secret
        return (token, secret)
    }

    func setAccessCredentials(token: String?, secret: String?) async {
        accessToken = token
        accessTokenSecret = secret
        if token == nil {
            username = nil
        }
    }

    func getUsername() async throws -> String {
        if let username = username {
            return username
        }

        guard accessToken != nil, accessTokenSecret != nil else {
            throw AuthError.missingAccessToken
        }

        let endpoint = "\(baseURL)/oauth/identity"
        let request = try createRequest("GET", endpoint)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(endpoint)
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let username = json["username"] as? String
        else {
            throw AuthError.invalidUsername(httpResponse.statusCode,
                                            String(data: data, encoding: .utf8))
        }

        self.username = username
        return username
    }

    // MARK: - Helpers

    private func generateNonce() -> String {
        let uuid = UUID().uuidString
        return uuid.replacingOccurrences(of: "-", with: "").lowercased()
    }

    private func generateTimestamp() -> String {
        String(Int(Date().timeIntervalSince1970))
    }

    private func generateOAuthSignature(
        method: String,
        url: String,
        parameters: [String: String]
    ) -> String {
        // Sort parameters alphabetically
        let sortedParams = parameters.sorted { $0.key < $1.key }

        // Create parameter string
        let paramString = sortedParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")

        // Create signature base string
        let signatureBase = "\(method)&\(url.rfc3986PercentEncoded)&\(paramString.rfc3986PercentEncoded)"

        // Create signing key
        let signingKey = "\(consumerSecret.rfc3986PercentEncoded)&\((accessTokenSecret ?? "").rfc3986PercentEncoded)"

        // Generate HMAC-SHA1 signature (Discogs docs only mention SHA1 or PLAINTEXT)
        let keyData = Data(signingKey.utf8)
        let messageData = Data(signatureBase.utf8)
        let signature = HMAC<Insecure.SHA1>.authenticationCode(
            for: messageData,
            using: SymmetricKey(data: keyData))

        return Data(signature).base64EncodedString()
    }

    private func generateOAuthSignature() -> String {
        // PLAINTEXT signature method: consumer_secret&token_secret
        "\(consumerSecret.rfc3986PercentEncoded)&\((accessTokenSecret ?? "").rfc3986PercentEncoded)"
    }

    func createOAuthHeader(
        method: String,
        endpoint: String
    ) -> String {
        var oauthParams: [String: String] = [
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": generateNonce(),
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": generateTimestamp(),
            "oauth_version": "1.0"
        ]

        if let token = accessToken {
            oauthParams["oauth_token"] = token
        }

        oauthParams["oauth_signature"] = generateOAuthSignature(
            method: method,
            url: endpoint,
            parameters: oauthParams
        )

        // Create Authorization header
        let authHeader = oauthParams
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\"\($0.value.rfc3986PercentEncoded)\"" }
            .joined(separator: ", ")

        return "OAuth \(authHeader)"
    }

    func createRequest(_ method: String, _ endpoint: String) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        let authHeader = createOAuthHeader(method: "GET", endpoint: endpoint)
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")

        return request
    }
}

extension APIService: API {}
