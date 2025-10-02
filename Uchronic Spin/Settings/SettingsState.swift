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

    /// `ModelQuery` loads the user data automatically when the `SettingsState`
    /// is created, watches the SwiftData DB for changes and updates the `users`
    /// array
    @ModelQuery private var users: [User]

    /// Computed property that reads/saves/deletes user data on persistent
    /// storage via SwiftData. Set to `nil` to delete.
    @MainActor var user: User? {
        get {
            return users.first
        }
        set {
            if let user = newValue {
                modelContext.insert(user)
            } else if let user = user {
                modelContext.delete(user)
            }
        }
    }

    @MainActor
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _users = ModelQuery(context: modelContext)
    }

    var hasError: Bool {
        get {
            error != nil
        }

        // need an explicit setter to bind to this comnputed property in SwiftUI
        set {
            if !newValue {
                error = nil
            }
        }
    }
}
