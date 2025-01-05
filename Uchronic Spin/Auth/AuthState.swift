//
//  AuthState.swift
//  Uchronic Spin
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation

@MainActor
final class AuthState: ObservableObject {
    @Published var isAuthenticating = false
    @Published var authError: AuthError?
    @Published var isAuthenticated = false

    var accessToken: String?
    var accessTokenSecret: String?
}
