//
//  MockCredentialStore.swift
//  Uchronic SpinTests
//
//  Created on 5/14/25.
//

import Foundation
@testable import Uchronic_Spin

class MockCredentialStore: CredentialStoring, @unchecked Sendable {
    var credentials: (token: String, secret: String)?
    var saveCredentialsCallCount = 0
    var loadCredentialsCallCount = 0
    var clearCredentialsCallCount = 0
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    var shouldThrowOnClear = false

    func saveCredentials(token: String, secret: String) async throws {
        saveCredentialsCallCount += 1

        if shouldThrowOnSave {
            throw KeychainError.saveFailure(errSecInternalError)
        }

        credentials = (token, secret)
    }

    func loadCredentials() async throws -> (token: String, secret: String)? {
        loadCredentialsCallCount += 1

        if shouldThrowOnLoad {
            throw KeychainError.loadFailure(errSecInternalError)
        }

        return credentials
    }

    func clearCredentials() async throws {
        clearCredentialsCallCount += 1

        if shouldThrowOnClear {
            throw KeychainError.deleteFailure(errSecInternalError)
        }

        credentials = nil
    }

    func reset() {
        credentials = nil
        saveCredentialsCallCount = 0
        loadCredentialsCallCount = 0
        clearCredentialsCallCount = 0
        shouldThrowOnSave = false
        shouldThrowOnLoad = false
        shouldThrowOnClear = false
    }
}
