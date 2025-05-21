//
//  AuthState.swift
//  Uchronic Spin
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation


/// State that can affect the authentication UI.
@MainActor
final class AuthState: ObservableObject {
    @Published var isAuthenticating = false
    @Published var authError: AuthError?
    @Published var isAuthenticated = false

    var hasError: Bool {
        get {
            authError != nil
        }
        set {
            if !newValue {
                authError = nil
            }
        }
    }
}
