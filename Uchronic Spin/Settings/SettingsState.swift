//
//  SettingsState.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/1/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import SwiftData


/// This state object describes whether the collection has been loaded
/// entirely or not, if an error occurred, and if we have user information
final class SettingsState: ObservableObject {
    @Published var error: Error?
    @Published var hasLoadedWholeCollection = false
    @MainActor var modelContext: ModelContext
    private let log: Logging

    // NB! it's fundamental this variable remains @Published for UI to work!
    @Published private var _user: User?

    /// Computed property that reads/saves/deletes user data on persistent
    /// storage via SwiftData. Set to `nil` to delete.
    @MainActor var user: User? {
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
    init(modelContext: ModelContext,
         log: Logging = Log.makeSettingsLog()) {
        self.modelContext = modelContext
        _user = modelContext.fetchUser()
        self.log = log
    }

    @MainActor
    func deleteUserMetadata() {
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
