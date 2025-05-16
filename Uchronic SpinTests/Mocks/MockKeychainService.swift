//
//  MockKeychainService.swift
//  Uchronic Spin
//  Created on 5/14/25.
//

import Foundation
@testable import Uchronic_Spin

final class MockKeychainService: KeychainServicing, @unchecked Sendable {
    private var storage: [String: Data] = [:]
    var saveCallCount = 0
    var loadCallCount = 0
    var deleteCallCount = 0
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    var shouldThrowOnDelete = false

    func save(key: String, data: Data) throws {
        saveCallCount += 1

        if shouldThrowOnSave {
            throw KeychainError.saveFailure(errSecInternalError)
        }

        storage[key] = data
    }

    func load(key: String) throws -> Data {
        loadCallCount += 1

        if shouldThrowOnLoad {
            throw KeychainError.loadFailure(errSecInternalError)
        }

        guard let data = storage[key] else {
            throw KeychainError.itemNotFound
        }

        return data
    }

    func delete(key: String) throws {
        deleteCallCount += 1

        if shouldThrowOnDelete {
            throw KeychainError.deleteFailure(errSecInternalError)
        }

        storage.removeValue(forKey: key)
    }

    func reset() {
        storage.removeAll()
        saveCallCount = 0
        loadCallCount = 0
        deleteCallCount = 0
        shouldThrowOnSave = false
        shouldThrowOnLoad = false
        shouldThrowOnDelete = false
    }
}
