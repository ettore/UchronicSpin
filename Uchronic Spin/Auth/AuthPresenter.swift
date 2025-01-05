//
//  AuthPresenter.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/4/25.
//

import Foundation


protocol AuthPresenting {
    var welcomeMessage: String { get }
    var authButtonTitle: String { get }
}

final class AuthPresenter: AuthPresenting {
    var welcomeMessage: String {
        "Welcome to Uchronic Spin"
    }

    var authButtonTitle: String {
        "Connect with Discogs"
    }
}
