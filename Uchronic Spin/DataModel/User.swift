//
//  User.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import SwiftData

protocol UserProtocol: PersistentModel {
    var username: String { get }
    var numberOfItems: Int { get }
    var collection: MusicCollection? { get set }
}


@Model
class User: UserProtocol {
    private(set) var username: String
    private(set) var numberOfItems: Int
    var collection: MusicCollection?

    init(username: String, numberOfItems: Int) {
        self.username = username
        self.numberOfItems = numberOfItems
    }
}
