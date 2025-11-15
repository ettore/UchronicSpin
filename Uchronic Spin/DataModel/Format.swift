//
//  Format.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import Foundation
import SwiftData


@Model
class Format: Decodable {
    private(set) var name: String
    private(set) var quantity: String
    private(set) var descriptions: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case quantity = "qty"
        case descriptions // e.g. 7", 45 RPM, Single, Mini, EP
        //case text // e.g. "blue labels"
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(String.self, forKey: .quantity)
        descriptions = try container.decode([String].self, forKey: .descriptions)
    }
}
