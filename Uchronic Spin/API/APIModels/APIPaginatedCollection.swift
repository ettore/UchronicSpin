//
//  PaginatedCollection.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 12/15/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//


struct APIPaginatedCollection {
    /// The releases on each page
    var pagedReleases: [Int: [APIRelease]]

    /// The pages that failed.
    var failedPages: Set<Int> // TODO: could expand this to save the errors

    let totalPages: Int
    let perPage: Int
    let username: String

    var releases: [APIRelease] {
        (0...totalPages).flatMap { pagedReleases[$0] ?? [] }
    }
}
