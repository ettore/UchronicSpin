//
//  Release.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/29/25.
//

import Foundation


struct APIRelease: Decodable, Sendable {
    let id: String
    let rating: Int

    // info stored inside "basic_information" dict in API response
    
    let url: URL?
    let masterId: String?
    let thumbURL: URL?
    let coverURL: URL?
    let title: String
    let year: Int?
    let formats: [APIFormat]
    let artists: [APIArtist]
    let genres: [String]
    let styles: [String]

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

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = "\(try container.decode(Int.self, forKey: .id))"
        rating = try container.decode(Int.self, forKey: .rating)

        // basic_information
        let info = try container.nestedContainer(keyedBy: CodingKeys.self,
                                                 forKey: .basicInformation)
        url = URL(string: try info.decode(String.self, forKey: .url))
        if let masterID = try info.decodeIfPresent(Int.self, forKey: .masterId),
           masterID != 0 {
            self.masterId = "\(masterID)"
        } else {
            self.masterId = nil
        }
        thumbURL = URL(string: try info.decode(String.self, forKey: .thumbURL))
        coverURL = URL(string: try info.decode(String.self, forKey: .coverURL))
        title = try info.decode(String.self, forKey: .title)
        if let year = try info.decodeIfPresent(Int.self, forKey: .year),
           year != 0 {
            self.year = year
        } else {
            self.year = nil
        }
        formats = try info.decode([APIFormat].self, forKey: .formats)
        artists = try info.decode([APIArtist].self, forKey: .artists)
        genres = try info.decode([String].self, forKey: .genres)
        styles = try info.decode([String].self, forKey: .styles)
    }
}


struct APIReleases: Decodable, Sendable {
    let releases: [APIRelease]

    enum CodingKeys: String, CodingKey {
        case pagination
        case releases
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.releases = try container.decode([APIRelease].self, forKey: .releases)
    }
}
