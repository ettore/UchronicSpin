//
//  Uchronic_SpinApp.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct UchronicSpinApp: App {
    @StateObject private var authState: AuthState
    private let authInteractor: AuthInteractor
    private let apiService: APIService
    private let modelContainer: ModelContainer
    private let log: Log

    init() {
        self.log = Log.make(for: "Main")
        modelContainer = try! ModelContainer(for: User.self)
        let state = AuthState(modelContext: modelContainer.mainContext)
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
                    log.debug("rootView modelContext: \(pointer(modelContainer.mainContext))")
                }
        }
        .modelContainer(modelContainer)
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
    }
}
