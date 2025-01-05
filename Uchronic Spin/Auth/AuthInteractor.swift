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
    private let service: OAuthService
    private var requestToken: String?
    private var requestTokenSecret: String?

    init(state: AuthState, service: OAuthService = OAuthService()) {
        self.state = state
        self.service = service
    }

    nonisolated func startAuth() async {
        await doStartAuth()
    }

    nonisolated func handleCallback(url: URL) async {
        await doHandleCallback(url: url)
    }

    private func doStartAuth() async {
        state.isAuthenticating = true

        do {
            let (token, secret) = try await service.getRequestToken()
            self.requestToken = token
            self.requestTokenSecret = secret

            if let url = URL(string: "https://discogs.com/oauth/authorize?oauth_token=\(token)") {
                await UIApplication.shared.open(url)
            }
        } catch {
            state.authError = error as? AuthError ?? .networkError(error)
            state.isAuthenticating = false
        }
    }

    @MainActor
    private func doHandleCallback(url: URL) async {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let requestToken = self.requestToken,
              let requestTokenSecret = self.requestTokenSecret,
              let verifier = components.queryItems?.first(where: { $0.name == "oauth_verifier" })?.value
        else {
            state.authError = .invalidRequestToken
            state.isAuthenticating = false
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
            state.isAuthenticating = false
        } catch {
            state.authError = error as? AuthError ?? .networkError(error)
            state.isAuthenticating = false
        }
    }
}
