//
//  BuildCollectionInteractor.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import SwiftData


enum CachePolicy: Int {
    case cacheIgnore
    case cachePreferred
    case cacheOnly
}


/// Protocol used by the UI for fetching and building the user metadata.
@MainActor
protocol BuildCollectionInteracting {
    var apiService: CollectionAPI {get}

    func loadCollection(with: ModelContext) async
    func setUpStateIfNeeded(with: ModelContext) -> SettingsState
    func fetchUserMetadataIfNeeded(cachePolicy: CachePolicy) async
    func fetchCollectionIfNeeded(cachePolicy: CachePolicy) async
    func deleteUserMetadata() async
}


/// Uses an API service to load user data (such as username and collection)
/// into a state object observable by SwiftUI (or other front-ends).
class BuildCollectionInteractor: BuildCollectionInteracting {
    let apiService: CollectionAPI
    @MainActor private var state: SettingsState?
    let log: Logging

    init(apiService: CollectionAPI,
         log: Logging = Log.makeSettingsLog()) {
        self.apiService = apiService
        self.log = log
    }

    /// Triggers SwiftData to load data from storage, or load collection from
    /// the network if needed.
    ///
    /// After loading from storage / network, collection data is then saved
    /// into a `SettingState` object.
    ///
    /// - Parameter modelContext: The SwiftData context to use.
    @MainActor
    func loadCollection(with modelContext: ModelContext) async {
        setUpSettingsState(with: modelContext)
        await fetchUserMetadataIfNeeded(cachePolicy: .cachePreferred)
        await fetchCollectionIfNeeded(cachePolicy: .cachePreferred)
    }

    /// Triggers SwiftData to load data from storage and save it into
    /// a `SettingState` object.
    ///
    /// - Parameter modelContext: The SwiftData context to use.
    /// - Returns: The state object that was loaded with data from storage.
    @discardableResult @MainActor
    private func setUpSettingsState(with modelContext: ModelContext) -> SettingsState {
        let state = SettingsState(modelContext: modelContext)
        self.state = state
        return state
    }

    @MainActor
    func setUpStateIfNeeded(with context: ModelContext) -> SettingsState {
        if let state = self.state {
            return state
        } else {
            return setUpSettingsState(with: context)
        }
    }

    @MainActor
    func fetchUserMetadataIfNeeded(cachePolicy: CachePolicy) async {
        guard let state = self.state else {
            log.error("No SettingsState available when attempting to fetch user metadata")
            return
        }

        if state.user != nil && cachePolicy != .cacheIgnore {
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
    func fetchCollectionIfNeeded(cachePolicy: CachePolicy) async {
        guard let user = self.state?.user else {
            log.error("No user metadata available when attempting to fetch collection")
            return
        }

        if let collection = user.collection {
            switch cachePolicy {
            case .cacheOnly:
                // only use what we have
                collection.rebuildReleasesSetIfNeeded()
                return
            case .cacheIgnore:
                await fetchWholeCollection(user: user)
            case .cachePreferred:
                if collection.failedPages.isEmpty {
                    collection.rebuildReleasesSetIfNeeded()
                    return
                } else {
                    // TODO: fetch missing pages
                }
            }
        } else {
            await fetchWholeCollection(user: user)
        }
    }

    @MainActor
    private func fetchWholeCollection(user: User) async {
        // we have no collection at all, so go fetch it
        let paginatedCollection = await apiService
            .getCollection(forUser: user.username,
                           numberOfItems: user.numberOfItems)

        user.collection = paginatedCollection.vendPersistentModel()
    }

    @MainActor
    func deleteUserMetadata() async {
        state?.deleteUserMetadata()
    }
}
