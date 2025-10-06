//
//  SettingsState.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/1/25.
//

import Foundation
import SwiftData


/// This state object describes whether the collection has been loaded
/// entirely or not, if an error occurred, and if we have user information
final class SettingsState: ObservableObject {
    @Published var error: Error?
    @Published var hasLoadedWholeCollection = false
    @MainActor var modelContext: ModelContext

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
                print("Error saving user \(user?.username ?? "nil") to ModelContext: \(error)")
            }
        }
    }

    @MainActor
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _user = modelContext.fetchUser()
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
