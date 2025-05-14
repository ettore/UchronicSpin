//
//  Uchronic_SpinApp.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import SwiftUI

@main
struct UchronicSpinApp: App {
    @StateObject private var authState: AuthState
    private let authInteractor: AuthInteractor

    init() {
        let state = AuthState()
        self._authState = StateObject(wrappedValue: state)
        self.authInteractor = AuthInteractor(state: state)

        // Check for existing credentials at launch
        Task { [self] in
            await self.authInteractor.checkExistingAuth()
        }
    }

    var body: some Scene {
        WindowGroup {
            if authState.isAuthenticated {
                Color.green
                    .ignoresSafeArea()
                    .overlay(
                        Button("Sign Out") {
                            Task {
                                await authInteractor.signOut()
                            }
                        }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                    )
            } else {
                AuthView(state: authState, interactor: authInteractor)
                    .onOpenURL { url in
                        Task {
                            await authInteractor.handleCallback(url: url)
                        }
                    }
            }
        }
    }
}
