//
//  BuildCollectionInteractor.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import SwiftData


/// Protocol used by the UI for fetching and building the user metadata.
@MainActor
protocol BuildCollectionInteracting {
    var apiService: CollectionAPI {get}

    @discardableResult
    func configureSettingsState(with: ModelContext) -> SettingsState
    func configureStateIfNeeded(with: ModelContext) ->  SettingsState
    func fetchUserMetadata() async
    func deleteUserMetadata() async
}


/// Uses the `apiService` to load user metadata into the `state`.
class BuildCollectionInteractor: BuildCollectionInteracting {
    let apiService: CollectionAPI
    @MainActor private var state: SettingsState?
    let log: Logging

    init(apiService: CollectionAPI,
         log: Logging = Log.makeSettingsLog()) {
        self.apiService = apiService
        self.log = log
    }

    @MainActor
    func configureSettingsState(with modelContext: ModelContext) -> SettingsState {
        self.state = SettingsState(modelContext: modelContext)
        return self.state!
    }

    @MainActor
    func configureStateIfNeeded(with context: ModelContext) ->  SettingsState {
        if let state = self.state {
            return state
        } else {
            return configureSettingsState(with: context)
        }
    }

    @MainActor
    func fetchUserMetadata() async {
        guard let state = self.state else {
            return
        }

        do {
            let (username, numberOfItems) = try await apiService.getUserMetadata()

            // store metadata in SwiftData DB
            let user = User(username: username, numberOfItems: numberOfItems)
            state.user = user
        } catch {
            state.error = error
            log.error("Failed to fetch user metadata: \(error)")
        }
    }

    @MainActor
    func deleteUserMetadata() async {
        state?.deleteUserMetadata()
    }
}
