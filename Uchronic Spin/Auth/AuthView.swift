//
//  AuthView.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import SwiftUI
import SwiftData


struct AuthView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var state: AuthState
    private let interactor: any AuthInteracting
    private let presenter: any AuthPresenting
    
    init(interactor: any AuthInteracting,
         presenter: (any AuthPresenting)) {
        _state = StateObject(wrappedValue: interactor.state)
        self.interactor = interactor
        self.presenter = presenter
    }
    
    var body: some View {
        Group {
            VStack(spacing: 24) {
                Text(presenter.welcomeMessage)
                    .font(.title)
                    .fontWeight(.bold)

                Button(presenter.authButtonTitle) {
                    Task {
                        await interactor.startAuth(appOpener: UIApplication.shared)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(state.isAuthenticating) //TODO: don't show at all
            }
            .padding()
            .alert("Authentication Error",
                   isPresented: $state.hasError
            ) {
                       Button("OK", role: .cancel) {}
                   } message: {
                       if let error = state.authError {
                           Text(error.userFriendlyMessage)
                       }
                   }
        }
        // re-enable sign in button if not authenticated
        .onChange(of: scenePhase) { oldPhase, newPhase in
            Task {
                let isActive = (newPhase == .active)
                await interactor
                    .resetIsAuthenticatingIfNeeded(sceneActive: isActive)
            }
        }
    }
}

#Preview {
    AuthView(
        interactor: AuthInteractor(
            state: AuthState(persistenceContext: try! ModelContainer(for: User.self).mainContext),
            apiService: APIService(log: LogFactory.makeAuthLog()),
            credentialStore: CredentialStore(
                keychainService: KeychainService(serviceName: "AuthViewPreview")),
            log: LogFactory.makeAuthLog()
        ),
        presenter: AuthPresenter()
    )
}
