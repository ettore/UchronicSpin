//
//  Release.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/29/25.
//

import Foundation
import SwiftData


@Model
class Release: Decodable {
    private(set) var id: String
    private(set) var url: URL
    private(set) var rating: Int
    private(set) var masterId: String
    private(set) var masterURL: URL?
    private(set) var thumbURL: URL?
    private(set) var coverURL: URL?
    private(set) var title: String
    private(set) var year: Int
    private(set) var formats: [Format]
    private(set) var artists: [Artist]
    private(set) var genres: [String]
    private(set) var styles: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case url = "resource_url"
        case rating
        case masterId = "master_id"
        case masterURL = "master_url"
        case thumbURL = "thumb"
        case coverURL = "cover_image"
        case title
        case year
        case formats
        case artists
        case genres
        case styles
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        url = URL(string: try container.decode(String.self, forKey: .url))!
        rating = try container.decode(Int.self, forKey: .rating)
        masterId = try container.decode(String.self, forKey: .masterId)
        masterURL = URL(string: try container.decode(String.self, forKey: .masterURL))
        thumbURL = URL(string: try container.decode(String.self, forKey: .thumbURL))
        coverURL = URL(string: try container.decode(String.self, forKey: .coverURL))
        title = try container.decode(String.self, forKey: .title)
        year = try container.decode(Int.self, forKey: .year)
        formats = try container.decode([Format].self, forKey: .formats)
        artists = try container.decode([Artist].self, forKey: .artists)
        genres = try container.decode([String].self, forKey: .genres)
        styles = try container.decode([String].self, forKey: .styles)
    }
}
