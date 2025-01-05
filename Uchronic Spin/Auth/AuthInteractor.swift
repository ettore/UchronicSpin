//
//  AuthInteractor.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation
import AuthenticationServices
import SwiftUI

protocol AuthInteracting: Sendable {
    func startAuth() async
    func handleCallback(url: URL) async
}

@MainActor
final class AuthInteractor: AuthInteracting {
    private let state: AuthState
    private let service: OAuthAPI
    private var requestToken: String?
    private var requestTokenSecret: String?

    init(state: AuthState, service: OAuthAPI = OAuthService()) {
        self.state = state
        self.service = service
    }

    func startAuth() async {
        state.isAuthenticating = true

        do {
            let (token, secret) = try await service.getRequestToken()

            self.requestToken = token
            self.requestTokenSecret = secret

            if let url = service.getAuthorizationURL(token: token) {
                await UIApplication.shared.open(url)
            }
        } catch {
            state.authError = error as? AuthError ?? .networkError(error)
            state.isAuthenticating = false
        }
    }

    func handleCallback(url: URL) async {
        defer {
            state.isAuthenticating = false
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let verifier = components?.queryItems?.first(where: {
            $0.name == service.verifierParam
        })?.value

        guard let requestToken = requestToken,
              let requestTokenSecret = requestTokenSecret
        else {
            state.authError = .missingRequestToken
            return
        }

        guard let verifier = verifier else {
            state.authError = .invalidRequestToken
            return
        }

        do {
            let (token, secret) = try await service.getAccessToken(
                requestToken: requestToken,
                requestTokenSecret: requestTokenSecret,
                verifier: verifier
            )

            state.accessToken = token
            state.accessTokenSecret = secret
            state.isAuthenticated = true
        } catch {
            state.authError = error as? AuthError ?? .networkError(error)
        }
    }
}
