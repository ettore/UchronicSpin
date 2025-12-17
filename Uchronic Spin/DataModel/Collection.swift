//
//  Collection.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 12/15/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//


import SwiftData


@Model
class Collection {
    private var _releases: [Release]
    @Transient private(set) var releases: Set<Release> = []

    /// The pages that failed to load.
    var failedPages: Set<Int>

    private(set) var totalPages: Int
    private(set) var perPage: Int

    init(releases: [Release],
         failedPages: Set<Int>,
         totalPages: Int,
         perPage: Int) {
        self._releases = releases
        self.failedPages = failedPages
        self.totalPages = totalPages
        self.perPage = perPage
        self.releases = Set(_releases)
    }

    func rebuildReleasesSetIfNeeded() {
        if releases.isEmpty {
            releases = Set(_releases)
        }
    }
}


extension APIPaginatedCollection {
    func vendPersistentModel() -> Collection {
        // Convert the API model's paged releases into persistent Release models
        let releases = pagedReleases.reduce([]) { partialResult, keyValue in
            partialResult + keyValue.value.map { $0.vendPersistentModel() }
        }

        return Collection(
            releases: releases,
            failedPages: failedPages,
            totalPages: totalPages,
            perPage: perPage
        )
    }
}
