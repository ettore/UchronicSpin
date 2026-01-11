//
//  BuildCollectionInteractor.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation


enum CachePolicy: Int {
    case cacheIgnore
    case cachePreferred
    case cacheOnly
}


/// Protocol used by the UI for fetching user's data, including their
/// collection and other metadata, and build related data structures.
@MainActor
protocol BuildCollectionInteracting {
    var apiService: CollectionAPI {get}

    func loadCollection(with: UserModelContext) async
    func setUpStateIfNeeded(with: UserModelContext) -> SettingsState
    func fetchUserMetadataIfNeeded(cachePolicy: CachePolicy) async
    func fetchCollectionIfNeeded(cachePolicy: CachePolicy) async
    func deleteAllUserData() async
}


/// Fetches and builds the user's music collection from Discogs.
/// 
/// Uses an API service to load user data (such as username and collection)
/// into a state object observable by SwiftUI (or other front-ends).
class BuildCollectionInteractor: BuildCollectionInteracting {
    let apiService: CollectionAPI
    @MainActor private var state: SettingsState?
    let log: Logging

    init(apiService: CollectionAPI, log: Logging) {
        self.apiService = apiService
        self.log = log
    }

    /// Load data from persistent storage or network if needed.
    ///
    /// After loading from storage / network, collection data is then saved
    /// into a `SettingState` object.
    ///
    /// - Parameter persistenceContext: The persistence system to use.
    @MainActor
    func loadCollection(with persistenceContext: UserModelContext) async {
        setUpSettingsState(with: persistenceContext)
        await fetchUserMetadataIfNeeded(cachePolicy: .cachePreferred)
        await fetchCollectionIfNeeded(cachePolicy: .cachePreferred)
    }

    /// Triggers persistence layer to load data and save it into
    /// a `SettingState` object.
    ///
    /// - Parameter persistenceContext: The persistence system to use to
    /// store data, such as SwiftData.
    /// - Returns: The state object that was loaded with data from storage.
    @discardableResult @MainActor
    private func setUpSettingsState(with persistenceContext: UserModelContext) -> SettingsState {
        let state = SettingsState(persistenceContext: persistenceContext, log: log)
        self.state = state
        return state
    }

    @MainActor
    func setUpStateIfNeeded(with context: UserModelContext) -> SettingsState {
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
            let (username, numberOfItems) = try await apiService.getCollectionMetadata()

            // store user in state object (which will take care of persisting it)
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
    private func fetchWholeCollection(user: any UserProtocol) async {
        // we have no collection at all, so go fetch it
        let paginatedCollection = await apiService
            .getCollection(forUser: user.username,
                           numberOfItems: user.numberOfItems)

        user.collection = paginatedCollection.vendPersistentModel()
    }

    @MainActor
    func deleteAllUserData() async {
        state?.deleteAllUserData()
    }
}
