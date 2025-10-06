//
//  ModelContext+Uchronic.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/6/25.
//

import SwiftData


protocol UserModelContext {
    func saveUser(_ user: User?) throws
}

extension ModelContext: UserModelContext {
    func fetchUser() -> User? {
        (try? fetch(FetchDescriptor<User>()))?.first
    }

    func saveUser(_ user: User?) throws {
        try delete(model: User.self)
        if let user = user {
            insert(user)
        }
    }
}
