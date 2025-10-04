//
//  Uchronic_SpinApp.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import SwiftUI
import SwiftData

@main
struct UchronicSpinApp: App {
    @Environment(\.modelContext) var modelContext
    @StateObject private var authState: AuthState
    private let authInteractor: AuthInteractor
    private let apiService: APIService

    init() {
        let state = AuthState()
        self._authState = StateObject(wrappedValue: state)
        self.apiService = APIService()
        self.authInteractor = AuthInteractor(state: state, apiService: apiService)

        // Check for existing credentials at launch
        Task { [self] in
            await self.authInteractor.loadExistingAuth()
        }
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .task {
                    print("App modelContext: \(pointer(modelContext))")
                    authState.modelContext = modelContext
                }
        }
    }

    private var rootView: some View {
        Group {
            if authState.isAuthenticated {
                MainView(apiService: apiService)
                    .onSignOut {
                        Task {
                            await authInteractor.signOut()
                        }
                    }
            } else {
                AuthView(state: authState, interactor: authInteractor)
                    .onOpenURL { url in
                        Task {
                            await authInteractor.setUpStateFetchingAccessToken(from: url)
                        }
                    }
            }
        }
        .modelContainer(for: User.self)
    }
}
