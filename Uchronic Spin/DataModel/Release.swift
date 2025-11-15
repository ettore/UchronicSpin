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
    private(set) var rating: Int

    // stored inside "basic_information" dict
    private(set) var url: URL?
    private(set) var masterId: String
    private(set) var masterURL: URL?
    private(set) var thumbURL: URL?
    private(set) var coverURL: URL?
    private(set) var title: String
    private(set) var year: Int?
    private(set) var formats: [Format]
    private(set) var artists: [Artist]
    private(set) var genres: [String]
    private(set) var styles: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case rating
        case basicInformation = "basic_information"
        case url = "resource_url"
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
        id = "\(try container.decode(Int.self, forKey: .id))"
        rating = try container.decode(Int.self, forKey: .rating)

        // basic_information
        let info = try container.nestedContainer(keyedBy: CodingKeys.self,
                                                 forKey: .basicInformation)
        url = URL(string: try info.decode(String.self, forKey: .url))
        masterId = "\(try info.decode(Int.self, forKey: .masterId))"
        masterURL = URL(string: try info.decode(String.self, forKey: .masterURL))
        thumbURL = URL(string: try info.decode(String.self, forKey: .thumbURL))
        coverURL = URL(string: try info.decode(String.self, forKey: .coverURL))
        title = try info.decode(String.self, forKey: .title)
        if let year = try info.decodeIfPresent(Int.self, forKey: .year) {
            if year != 0 {
                self.year = year
            }
        }
        formats = try info.decode([Format].self, forKey: .formats)
        artists = try info.decode([Artist].self, forKey: .artists)
        genres = try info.decode([String].self, forKey: .genres)
        styles = try info.decode([String].self, forKey: .styles)
    }
}
