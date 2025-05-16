//
//  AuthKeychainManagerTests.swift
//  Uchronic SpinTests
//  Created on 5/14/25.
//

import XCTest
@testable import Uchronic_Spin

class AuthKeychainManagerTests: XCTestCase {

    private var mockKeychainService: MockKeychainService!
    private var keychainManager: AuthKeychainManager!

    override func setUp() {
        super.setUp()
        mockKeychainService = MockKeychainService()
        keychainManager = AuthKeychainManager(keychainService: mockKeychainService)
    }

    override func tearDown() {
        mockKeychainService = nil
        keychainManager = nil
        super.tearDown()
    }

    func testSaveCredentials() async throws {
        // Test saving valid credentials
        try await keychainManager.saveCredentials(token: "testToken", secret: "testSecret")

        // Verify mock service was called twice (once for token, once for secret)
        XCTAssertEqual(mockKeychainService.saveCallCount, 2)
    }

    func testSaveCredentialsFailure() async {
        // Setup mock to throw on save
        mockKeychainService.shouldThrowOnSave = true

        // Attempt to save credentials should throw
        do {
            try await keychainManager.saveCredentials(token: "testToken", secret: "testSecret")
            XCTFail("Expected save to throw an error")
        } catch {
            // Success - we expected an error
            XCTAssertTrue(error is KeychainError)
        }
    }

    func testLoadCredentials() async throws {
        // First save credentials
        try await keychainManager.saveCredentials(token: "testToken", secret: "testSecret")

        // Reset call count
        mockKeychainService.loadCallCount = 0

        // Load credentials
        let credentials = try await keychainManager.loadCredentials()

        // Verify mock service was called twice (once for token, once for secret)
        XCTAssertEqual(mockKeychainService.loadCallCount, 2)

        // Verify loaded credentials match what we saved
        XCTAssertEqual(credentials?.token, "testToken")
        XCTAssertEqual(credentials?.secret, "testSecret")
    }

    func testLoadCredentialsWhenNoneExist() async throws {
        // Load credentials when none exist should return nil
        let credentials = try await keychainManager.loadCredentials()
        XCTAssertNil(credentials)
    }

    func testLoadCredentialsFailure() async {
        // First save credentials
        try! await keychainManager.saveCredentials(token: "testToken",
                                                   secret: "testSecret")

        // Setup mock to throw on load
        mockKeychainService.shouldThrowOnLoad = true

        // Attempt to load credentials should throw
        do {
            _ = try await keychainManager.loadCredentials()
            XCTFail("Expected load to throw an error")
        } catch {
            // Success - we expected an error
            XCTAssertTrue(error is KeychainError)
        }
    }

    func testClearCredentials() async throws {
        // First save credentials
        try await keychainManager.saveCredentials(token: "testToken",
                                                  secret: "testSecret")

        // Reset
        mockKeychainService.deleteCallCount = 0
        try await keychainManager.clearCredentials()

        // Verify mock service was called twice (once for token, once for secret)
        XCTAssertEqual(mockKeychainService.deleteCallCount, 2)

        // Verify credentials are actually gone
        let credentials = try await keychainManager.loadCredentials()
        XCTAssertNil(credentials)
    }

    func testClearCredentialsFailure() async {
        // First save credentials
        try! await keychainManager.saveCredentials(token: "testToken",
                                                   secret: "testSecret")

        // Setup mock to throw on delete
        mockKeychainService.shouldThrowOnDelete = true

        // Attempt to clear credentials should throw
        do {
            try await keychainManager.clearCredentials()
            XCTFail("Expected clear to throw an error")
        } catch {
            // Success - we expected an error
            XCTAssertTrue(error is KeychainError)
        }
    }
}
