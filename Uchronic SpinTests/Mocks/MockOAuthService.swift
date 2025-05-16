//
//  MockOAuthService.swift
//  Uchronic SpinTests
//  Created on 5/14/25.
//

import Foundation
@testable import Uchronic_Spin

class MockOAuthService: OAuthAPI, @unchecked Sendable {
    let verifierParam: String = "oauth_verifier"
    let tokenURL = URL(string: "https://example.com/callback?oauth_verifier=mock_verifier")!
    var requestTokenResponse: (token: String, secret: String) = ("mock_request_token", "mock_request_token_secret")
    var accessTokenResponse: (token: String, secret: String) = ("mock_access_token", "mock_access_token_secret")
    var shouldThrowOnRequestToken = false
    var shouldThrowOnAccessToken = false
    var getRequestTokenCallCount = 0
    var getAccessTokenCallCount = 0

    func getToken(requestToken: String?,
                  requestTokenSecret: String?,
                  verifier: String?) async throws -> (token: String, secret: String) {

        // This is a request token fetch if all parameters are nil
        if requestToken == nil && requestTokenSecret == nil && verifier == nil {
            getRequestTokenCallCount += 1

            if shouldThrowOnRequestToken {
                throw AuthError.invalidRequestToken
            }

            return requestTokenResponse
        }
        // Otherwise it's an access token fetch
        else {
            getAccessTokenCallCount += 1

            if shouldThrowOnAccessToken {
                throw AuthError.invalidAccessToken
            }

            // Validate the input parameters
            guard
                let requestToken = requestToken,
                let requestTokenSecret = requestTokenSecret,
                let verifier = verifier,
                !requestToken.isEmpty,
                !requestTokenSecret.isEmpty,
                !verifier.isEmpty
            else {
                throw AuthError.invalidRequestToken
            }

            return accessTokenResponse
        }
    }

    nonisolated func getAuthorizationURL(token: String) -> URL? {
        return URL(string: "https://example.com/oauth/authorize?oauth_token=\(token)")
    }

    func reset() {
        requestTokenResponse = ("mock_request_token", "mock_request_token_secret")
        accessTokenResponse = ("mock_access_token", "mock_access_token_secret")
        shouldThrowOnRequestToken = false
        shouldThrowOnAccessToken = false
        getRequestTokenCallCount = 0
        getAccessTokenCallCount = 0
    }
}
