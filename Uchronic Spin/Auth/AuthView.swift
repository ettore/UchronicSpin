//
//  AuthView.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var state: AuthState
    private let interactor: AuthInteracting
    private let presenter: AuthPresenting
    
    init(state: AuthState = AuthState(),
         interactor: AuthInteracting? = nil,
         presenter: AuthPresenting? = nil) {
        _state = StateObject(wrappedValue: state)
        self.interactor = interactor ?? AuthInteractor(state: state)
        self.presenter = presenter ?? AuthPresenter()
    }
    
    var body: some View {
        Group {
            VStack(spacing: 24) {
                Text(presenter.welcomeMessage)
                    .font(.title)
                    .fontWeight(.bold)
                
                Button(presenter.authButtonTitle) {
                    Task {
                        await interactor.startAuth()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(state.isAuthenticating)
            }
            .padding()
            .alert("Authentication Error",
                   isPresented: $state.hasError
            ) {
                       Button("OK", role: .cancel) {}
                   } message: {
                       if let error = state.authError {
                           Text(error.localizedDescription)
                       }
                   }
        }
    }
}

#Preview {
    AuthView()
}
