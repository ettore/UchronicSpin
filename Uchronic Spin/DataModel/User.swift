//
//  User.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import SwiftData


@Model
class User {
    private(set) var username: String
    private(set) var numberOfItems: Int
    var collection: Collection?

    init(username: String, numberOfItems: Int) {
        self.username = username
        self.numberOfItems = numberOfItems
    }
}
