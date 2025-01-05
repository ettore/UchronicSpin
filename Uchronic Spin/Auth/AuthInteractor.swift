//
//  AuthInteractor.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation


protocol AuthInteracting {
    func startAuth() async
}


final class AuthInteractor: AuthInteracting {
    private let state: AuthState

    init(state: AuthState) {
        self.state = state
    }

    func startAuth() async {
        await state.isAuthenticating = true
        // TODO: Implement OAuth flow
    }
}

