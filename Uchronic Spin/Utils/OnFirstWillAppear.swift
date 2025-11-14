//
//  SwiftUIUtils.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 11/12/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import SwiftUI


extension View {
    func onFirstWillAppear(perform action: @escaping () async -> Void) -> some View {
        modifier(OnFirstWillAppearModifier(action: action))
    }

    func onFirstWillAppear(perform action: @escaping () -> Void) -> some View {
        modifier(OnFirstWillAppearModifier(action: {
            action()
        }))
    }
}

struct OnFirstWillAppearModifier: ViewModifier {
    @State private var hasEverTriggered = false

    /// Action to run exactly once before the view appears.
    let action: () async -> Void

    func body(content: Content) -> some View {
        content.task {
            guard !hasEverTriggered else {
                return
            }
            hasEverTriggered = true
            await action()
        }
    }
}

