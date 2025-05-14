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
    func checkExistingAuth() async
    func signOut() async
}

@MainActor
final class AuthInteractor: AuthInteracting {
    private let state: AuthState
    private let service: OAuthAPI
    private let keychainManager: AuthKeychainManaging
    private var requestToken: String?
    private var requestTokenSecret: String?

    init(state: AuthState,
         service: OAuthAPI = OAuthService(),
         keychainManager: AuthKeychainManaging = AuthKeychainManager()) {
        self.state = state
        self.service = service
        self.keychainManager = keychainManager
    }

    func checkExistingAuth() async {
        do {
            if let credentials = try await keychainManager.loadCredentials() {
                state.accessToken = credentials.token
                state.accessTokenSecret = credentials.secret
                state.isAuthenticated = true
            }
        } catch {
            print("Failed to load credentials: \(error)")
            // If loading fails, we simply don't set the user as authenticated
        }
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

            // Save credentials to keychain
            try await keychainManager.saveCredentials(token: token, secret: secret)

            // Update state
            state.accessToken = token
            state.accessTokenSecret = secret
            state.isAuthenticated = true
        } catch {
            state.authError = error as? AuthError ?? .networkError(error)
        }
    }

    func signOut() async {
        do {
            try await keychainManager.clearCredentials()
            state.accessToken = nil
            state.accessTokenSecret = nil
            state.isAuthenticated = false
        } catch {
            print("Error clearing credentials: \(error)")
            // Continue with sign out even if keychain delete fails
            state.accessToken = nil
            state.accessTokenSecret = nil
            state.isAuthenticated = false
        }
    }
}
