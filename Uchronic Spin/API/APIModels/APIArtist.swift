//
//  Artist.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import Foundation


struct APIArtist: Decodable, Sendable {
    /// If a release was voted to be removed by the community, and the user
    /// had that release in the collection, somehow Discogs returns a nil
    /// artist ID for that release.
    let id: String?

    let name: String
    let anv: String?
    let role: String?

    /// If a release was voted to be removed by the community, and the user
    /// had that release in the collection, somehow Discogs returns a nil
    /// resource URL for that release.
    let resourceURL: URL?

    /*
     Discogs has a couple more fields that i am currently ignoring:
     case join // I think this is to "join" artists in releases with
               // multiple authors
     case tracks // to express the per-track contributions of an artist. Does
                 // not seem used on the "artists" field of api responses for:
                 // /users/<user>/collection/folders/0/releases
     */
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case anv // Artist Name Variation
        case role // usually instruments played
        case resourceURL = "resource_url" // api link to artist
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let id = try container.decodeIfPresent(Int.self, forKey: .id) {
            self.id = "\(id)"
        } else {
            self.id = nil
        }
        name = try container.decode(String.self, forKey: .name)
        if let anv = try container.decodeIfPresent(String.self, forKey: .anv),
           !anv.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.anv = anv
        } else {
            self.anv = nil
        }
        if let role = try container.decodeIfPresent(String.self, forKey: .role),
           !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.role = role
        } else {
            self.role = nil
        }

        resourceURL = try container.decodeIfPresent(URL.self, forKey: .resourceURL)
    }
}
