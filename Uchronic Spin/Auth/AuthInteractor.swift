//
//  AuthInteractor.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftUI

protocol AuthInteracting: Sendable {
    var state: AuthState {get}
    func startAuth() async
    func setUpStateFetchingAccessToken(from: URL) async
    func loadExistingAuth() async
    func signOut() async
    func resetIsAuthenticatingIfNeeded(forScenePhase phase: ScenePhase) async
}

@MainActor
final class AuthInteractor: AuthInteracting {
    let state: AuthState
    private let service: OAuthAPI
    private let credentialStore: CredentialStoring
    private var requestToken: String?
    private var requestTokenSecret: String?
    private let log: Logging

    init(state: AuthState,
         apiService: OAuthAPI,
         credentialStore: CredentialStoring = CredentialStore(),
         log: Logging = Log.makeAuthLog()) {
        self.state = state
        self.service = apiService
        self.credentialStore = credentialStore
        self.log = log
    }

    func loadExistingAuth() async {
        guard !state.isAuthenticated else {
            return
        }
        
        do {
            if let credentials = try await credentialStore.loadCredentials() {
                await service.setAccessCredentials(token: credentials.token,
                                                   secret: credentials.secret)
                state.isAuthenticated = true
            }
        } catch {
            log.warning("Failed to load credentials from keychain", error)
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
            log.error("Failed to get request token", error)
        }
    }

    /// Loads access token and secret and saves them into keychain.
    ///
    /// Also sets `isAuthenticated` flag into `AuthState`.
    func setUpStateFetchingAccessToken(from url: URL) async {
        defer {
            state.isAuthenticating = false
        }

        guard let requestToken = requestToken,
              let requestTokenSecret = requestTokenSecret
        else {
            state.authError = .missingRequestToken
            log.error("Attempting to fetch access token without a request token/secret")
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let verifier = components?.queryItems?.first(where: {
            $0.name == service.verifierParam
        })?.value

        guard let verifier = verifier else {
            // if can't find the verifier, we probably had a bad request token
            state.authError = .invalidRequestToken
            log.error("Obtained a request token without an OAuth verifier")
            return
        }

        do {
            let (token, secret) = try await service.getAccessToken(
                requestToken: requestToken,
                requestTokenSecret: requestTokenSecret,
                verifier: verifier
            )

            // Save credentials to keychain
            try await credentialStore.saveCredentials(token: token,
                                                      secret: secret)
            // Update state
            await service.setAccessCredentials(token: token, secret: secret)
            state.isAuthenticated = true
        } catch {
            if let authError = error as? AuthError {
                state.authError = authError
            } else if let keychainError = error as? KeychainError {
                state.authError = .keychainError(keychainError)
            } else {
                state.authError = .networkError(error)
            }
            log.error("Error getting or saving access token", error)
        }
    }

    func signOut() async {
        do {
            try await credentialStore.clearCredentials()
            await service.setAccessCredentials(token: nil, secret: nil)
            state.isAuthenticated = false
        } catch {
            log.warning("Error clearing credentials from keychain", error)
            // Continue with sign out even if keychain delete fails
            await service.setAccessCredentials(token: nil, secret: nil)
            state.isAuthenticated = false
        }
    }

    func resetIsAuthenticatingIfNeeded(forScenePhase phase: ScenePhase) async {
        // if there was an error, this is already taken care
        if state.hasError == false && phase == .active {
            state.isAuthenticating = false
        }
    }
}
