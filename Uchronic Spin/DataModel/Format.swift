//
//  Format.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 12/16/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import SwiftData


@Model
class Format {
    private(set) var name: String
    private(set) var quantity: String
    private(set) var descriptions: [String]
    private(set) var text: String?

    init(name: String, quantity: String, descriptions: [String], text: String?) {
        self.name = name
        self.quantity = quantity
        self.descriptions = descriptions
        self.text = text
    }
}

extension Format: Hashable {
    static func == (lhs: Format, rhs: Format) -> Bool {
        lhs.name == rhs.name
        && lhs.quantity == rhs.quantity
        && lhs.descriptions == rhs.descriptions
        && lhs.text == rhs.text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name + quantity + descriptions.joined() + (text ?? ""))
    }
}


extension APIFormat {
    func vendPersistentModel() -> Format {
        Format(name: name,
               quantity: quantity,
               descriptions: descriptions,
               text: text)
    }
}
