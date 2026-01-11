//
//  ModelContext+Uchronic.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/6/25.
//

import SwiftData


protocol UserModelSaving {
    func saveUser(_ user: (any UserProtocol)?) throws
}

protocol UserModelContext: UserModelSaving {
    func fetchUser() -> (any UserProtocol)?
}


extension ModelContext: UserModelContext {
    func fetchUser() -> (any UserProtocol)? {
        (try? fetch(FetchDescriptor<User>()))?.first
    }

    func saveUser(_ user: (any UserProtocol)?) throws {
        try delete(model: User.self)
        if let user = user {
            insert(user)
        }
    }
}
