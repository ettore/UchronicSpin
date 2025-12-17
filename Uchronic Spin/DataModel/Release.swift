//
//  Release.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 12/15/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import SwiftData


@Model
class Release {
    private(set) var id: String
    private(set) var rating: Int
    private(set) var url: URL?
    private(set) var masterId: String?
    private(set) var thumbURL: URL?
    private(set) var coverURL: URL?
    private(set) var title: String
    private(set) var year: Int?
    private(set) var formats: [Format]
    private(set) var artists: [Artist]
    private(set) var genres: [String]
    private(set) var styles: [String]

    init(id: String,
         rating: Int,
         url: URL?,
         masterId: String?,
         thumbURL: URL?,
         coverURL: URL?,
         title: String,
         year: Int?,
         formats: [Format],
         artists: [Artist],
         genres: [String],
         styles: [String]) {
        self.id = id
        self.rating = rating
        self.url = url
        self.masterId = masterId
        self.thumbURL = thumbURL
        self.coverURL = coverURL
        self.title = title
        self.year = year
        self.formats = formats
        self.artists = artists
        self.genres = genres
        self.styles = styles
    }
}

extension Release: Hashable {
    static func == (lhs: Release, rhs: Release) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension APIRelease {
    func vendPersistentModel() -> Release {
        let persistedFormats = formats.map { $0.vendPersistentModel() }
        let persistedArtists = artists.map { $0.vendPersistentModel() }
        return Release(
            id: id,
            rating: rating,
            url: url,
            masterId: masterId,
            thumbURL: thumbURL,
            coverURL: coverURL,
            title: title,
            year: year,
            formats: persistedFormats,
            artists: persistedArtists,
            genres: genres,
            styles: styles
        )
    }
}

