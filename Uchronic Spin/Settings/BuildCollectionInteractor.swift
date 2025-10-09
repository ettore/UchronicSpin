//
//  BuildCollectionInteractor.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import SwiftData


protocol BuildCollectionInteracting: Sendable {
    var apiService: CollectionAPI {get}

    func fetchUserMetadata() async
    func deleteUserMetadata() async
}


@MainActor
class BuildCollectionInteractor: BuildCollectionInteracting {
    let apiService: CollectionAPI
    let state: SettingsState
    let log: Logging

    init(apiService: CollectionAPI,
         modelContext: ModelContext,
         log: Logging = Log.makeSettingsLog()) {
        self.apiService = apiService
        self.state = SettingsState(modelContext: modelContext)
        self.log = log
    }

    func fetchUserMetadata() async {
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

    func deleteUserMetadata() async {
        state.deleteUserMetadata()
    }
}
