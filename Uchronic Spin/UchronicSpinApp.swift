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
    private let log: Logging

    init() {
        self.log = Log.make(for: "AppMain")

        // TODO: remove this forced-escape. This will crash when the User model
        //       changes and SwiftData won't be able to migrate it to the
        //       new model.
        modelContainer = try! ModelContainer(for: User.self)
        
        let state = AuthState(modelContext: modelContainer.mainContext)
        self._authState = StateObject(wrappedValue: state)
        self.apiService = APIService(log: Log.makeAPIServiceLog())
        let keychain = KeychainService(
            serviceName: Bundle.main.bundleIdentifier ?? "com.howlingtree.Uchronic-Spin")
        let credsStore = CredentialStore(keychainService: keychain)
        self.authInteractor = AuthInteractor(state: state,
                                             apiService: apiService,
                                             credentialStore: credsStore,
                                             log: Log.makeAuthLog())
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .task {
                    // Check for existing credentials (and load if present)
                    await self.authInteractor.loadExistingAuth()
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
                AuthView(interactor: authInteractor, presenter: AuthPresenter())
                    .onOpenURL { url in
                        Task {
                            await authInteractor.setUpStateFetchingAccessToken(from: url)
                        }
                    }
            }
        }
    }
}
