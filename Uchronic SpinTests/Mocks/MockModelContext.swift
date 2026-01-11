//
//  MockModelContext.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/7/25.
//

@testable import Uchronic_Spin


class MockModelContext: UserModelContext {
    func fetchUser() -> (any UserProtocol)? {
        return nil
    }
    
    func saveUser(_ user: (any UserProtocol)?) throws {
    }
}
