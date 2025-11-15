//
//  Format.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import Foundation


struct APIFormat: Decodable, Sendable {
    let name: String
    let quantity: String
    let descriptions: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case quantity = "qty"
        case descriptions // e.g. 7", 45 RPM, Single, Mini, EP
        //case text // e.g. "blue labels"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(String.self, forKey: .quantity)
        descriptions = try container.decode([String].self, forKey: .descriptions)
    }
}
