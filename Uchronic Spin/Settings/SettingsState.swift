//
//  SettingsState.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/1/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import SwiftData


/// The state of all the user's settings.
///
/// This state object describes various user settings, such as:
/// - the user info;
/// - whether the collection has been loaded entirely or not;
/// - if an error occurred.
final class SettingsState: ObservableObject {
    @Published var error: Error?
    @Published var hasLoadedWholeCollection = false
    @MainActor var modelContext: ModelContext
    private let log: Logging

    // NB! it's fundamental this variable remains @Published for UI to work!
    @Published private var _user: (any UserProtocol)?

    /// Computed property that reads/saves/deletes user data on persistent
    /// storage via SwiftData. Set to `nil` to delete.
    @MainActor var user: (any UserProtocol)? {
        get {
            return _user
        }
        set {
            do {
                try modelContext.saveUser(newValue)
                _user = newValue
            } catch {
                log.error("Error saving user \(user?.username ?? "nil") to ModelContext", error)
            }
        }
    }

    @MainActor
    init(modelContext: ModelContext, log: Logging) {
        self.modelContext = modelContext
        _user = modelContext.fetchUser() // from SwiftData
        self.log = log
    }

    @MainActor
    func deleteAllUserData() {
        user = nil
    }

    var hasError: Bool {
        get {
            error != nil
        }

        // need an explicit setter to bind to this computed property in SwiftUI
        set {
            if !newValue {
                error = nil
            }
        }
    }
}
