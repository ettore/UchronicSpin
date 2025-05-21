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
    func setUpStateFetchingAccessToken(from: URL) async
    func loadExistingAuth() async
    func signOut() async
    func resetIsAuthenticatingIfNeeded(forScenePhase phase: ScenePhase) async
}

@MainActor
final class AuthInteractor: AuthInteracting {
    private let state: AuthState
    private let service: OAuthAPI
    private let keychainManager: AuthKeychainManaging
    private var requestToken: String?
    private var requestTokenSecret: String?
    private var accessToken: String?
    private var accessTokenSecret: String?

    init(state: AuthState,
         service: OAuthAPI = OAuthService(),
         keychainManager: AuthKeychainManaging = AuthKeychainManager()) {
        self.state = state
        self.service = service
        self.keychainManager = keychainManager
    }

    func loadExistingAuth() async {
        do {
            if let credentials = try await keychainManager.loadCredentials() {
                accessToken = credentials.token
                accessTokenSecret = credentials.secret
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

    func setUpStateFetchingAccessToken(from url: URL) async {
        defer {
            state.isAuthenticating = false
        }

        guard let requestToken = requestToken,
              let requestTokenSecret = requestTokenSecret
        else {
            state.authError = .missingRequestToken
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let verifier = components?.queryItems?.first(where: {
            $0.name == service.verifierParam
        })?.value

        guard let verifier = verifier else {
            // if we can't find the verifier, we probably had a bad request token
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
            try await keychainManager.saveCredentials(token: token,
                                                      secret: secret)
            // Update state
            accessToken = token
            accessTokenSecret = secret
            state.isAuthenticated = true
        } catch {
            if let authError = error as? AuthError {
                state.authError = authError
            } else if let keychainError = error as? KeychainError {
                state.authError = .keychainError(keychainError)
            } else {
                state.authError = .networkError(error)
            }
        }
    }

    func signOut() async {
        do {
            try await keychainManager.clearCredentials()
            accessToken = nil
            accessTokenSecret = nil
            state.isAuthenticated = false
        } catch {
            print("Error clearing credentials: \(error)")
            // Continue with sign out even if keychain delete fails
            accessToken = nil
            accessTokenSecret = nil
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

#if DEBUG
extension AuthInteractor {
    var accessToken_testAccessor: String? {
        get {
            return self.accessToken
        }
        set {
            self.accessToken = newValue
        }
    }
    var accessTokenSecret_testAccessor: String? {
        get {
            return self.accessTokenSecret
        }
        set {
            self.accessTokenSecret = newValue
        }
    }
}
#endif
