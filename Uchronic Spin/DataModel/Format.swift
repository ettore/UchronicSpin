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
    private var quantity: Int

    enum CodingKeys: String, CodingKey {
        case name
        case quantity = "qty"
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Int.self, forKey: .quantity)
    }
}
