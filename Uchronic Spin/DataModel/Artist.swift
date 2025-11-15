//
//  Artist.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import Foundation
import SwiftData


@Model
class Artist: Decodable {
    private(set) var id: String
    private(set) var name: String
    private(set) var anv: String?
    private(set) var role: String?
    private(set) var resourceURL: URL

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

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        self.id = "\(id)"
        name = try container.decode(String.self, forKey: .name)
        if let anv = try container.decodeIfPresent(String.self, forKey: .anv) {
            if !anv.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.anv = anv
            }
        }
        if let role = try container.decodeIfPresent(String.self, forKey: .role) {
            if !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.role = role
            }
        }
        resourceURL = try container.decode(URL.self, forKey: .resourceURL)
    }
}
