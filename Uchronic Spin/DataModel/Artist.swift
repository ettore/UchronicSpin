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

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case anv
        case role
        case resourceURL = "resource_url"
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        anv = try container.decodeIfPresent(String.self, forKey: .anv)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        resourceURL = try container.decode(URL.self, forKey: .resourceURL)
    }
}
