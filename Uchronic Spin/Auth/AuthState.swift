//
//  AuthState.swift
//  Uchronic Spin
//  Created by Ettore Pasquini on 1/4/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation


/// State that can affect the authentication UI.
///
/// This is not meant to capture the long-term authentication state of the
/// app, such as the current credentials.
@MainActor
final class AuthState: ObservableObject {
    @Published var isAuthenticating = false

    /// Any blocking authentication error that should be displayed to the user.
    @Published var authError: AuthError?
    
    @Published var isAuthenticated = false {
        didSet {
            if !isAuthenticated {
                do {
                    try persistenceContext?.saveUser(nil)
                } catch {
                    authError = .persistentStorageError(error)
                }
            }
        }
    }

    var persistenceContext: UserModelSaving?

    init(persistenceContext: UserModelSaving) {
        self.persistenceContext = persistenceContext
    }

    var hasError: Bool {
        get {
            authError != nil
        }

        // need a setter to use `hasError` as a binding in SwiftUI
        set {
            if !newValue {
                authError = nil
            }
        }
    }
}
