//
//  Artist.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 12/15/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//


import Foundation
import SwiftData


@Model
class Artist {
    /// If a release was voted to be removed by the community, and the user
    /// had that release in the collection, somehow Discogs returns a nil
    /// artist ID for that release.
    private(set) var id: String?
    private(set) var name: String
    private(set) var anv: String?
    private(set) var role: String?
    private(set) var resourceURL: URL?

    init(id: String?, name: String, anv: String?, role: String?, resourceURL: URL?) {
        self.id = id
        self.name = name
        self.anv = anv
        self.role = role
        self.resourceURL = resourceURL
    }
}


extension Artist: Hashable {
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        if lhs.id == rhs.id {
            if lhs.id == nil {
                return lhs.name == rhs.name
            } else {
                return true
            }
        } else {
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id ?? name)
    }
}


extension APIArtist {
    func vendPersistentModel() -> Artist {
        Artist(id: id, name: name, anv: anv, role: role, resourceURL: resourceURL)
    }
}
