//
//  SignOut.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 5/21/25.
//

import SwiftUI

/// Initiate sign out.
func uchronicSignOut() {
    NotificationCenter.default.post(name: .userDidSignOut, object: nil)
}

extension Notification.Name {
    static let userDidSignOut = Notification.Name("userDidSignOut")
}

extension View {
    /// Add this modifier to any View that needs to react to a sign-out event.
    func onSignOut(perform action: @escaping () -> Void) -> some View {
        modifier(SignOutModifier(action: action))
    }
}

struct SignOutModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .userDidSignOut)) { _ in
                action()
            }
    }
}
