//
//  User.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import SwiftData


@Model
class User {
    var username: String
    var numberOfItems: Int

    init(username: String, numberOfItems: Int) {
        self.username = username
        self.numberOfItems = numberOfItems
    }
}
