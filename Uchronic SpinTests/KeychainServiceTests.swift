//
//  KeychainServiceTests.swift
//  Uchronic Spin
//  Created on 5/14/25.
//

import XCTest
@testable import Uchronic_Spin

class KeychainServiceTests: XCTestCase {

    private var keychainService: KeychainService!
    private let testServiceName = "com.uchronicspin.tests"
    private let testKey = "testKey"
    private let testData = "testData".data(using: .utf8)!

    override func setUp() {
        super.setUp()
        keychainService = KeychainService(serviceName: testServiceName)
        // Ensure the test key doesn't exist in the keychain
        try? keychainService.delete(key: testKey)
    }

    override func tearDown() {
        try? keychainService.delete(key: testKey)
        keychainService = nil
        super.tearDown()
    }

    func testSaveAndLoad() throws {
        try keychainService.save(key: testKey, data: testData)

        let loadedData = try keychainService.load(key: testKey)
        XCTAssertEqual(loadedData, testData)
    }

    func testLoadNonexistentKey() {
        // Attempt to load a key that doesn't exist
        XCTAssertThrowsError(try keychainService.load(key: "nonexistentKey")) { error in
            XCTAssertTrue(error is KeychainError)
            if let keychainError = error as? KeychainError {
                XCTAssertEqual(String(describing: keychainError),
                               String(describing: KeychainError.itemNotFound))
            }
        }
    }

    func testOverwriteExistingKey() throws {
        // Save initial data
        try keychainService.save(key: testKey, data: testData)

        // Overwrite with new data
        let newData = "newData".data(using: .utf8)!
        try keychainService.save(key: testKey, data: newData)

        // Load and verify it's been overwritten
        let loadedData = try keychainService.load(key: testKey)
        XCTAssertEqual(loadedData, newData)
    }

    func testDelete() throws {
        // Save data
        try keychainService.save(key: testKey, data: testData)

        // Delete it
        try keychainService.delete(key: testKey)

        // Verify it's gone
        XCTAssertThrowsError(try keychainService.load(key: testKey)) { error in
            XCTAssertTrue(error is KeychainError)
            if let keychainError = error as? KeychainError {
                XCTAssertEqual(String(describing: keychainError),
                               String(describing: KeychainError.itemNotFound))
            }
        }
    }

    func testDeleteNonexistentKey() {
        // Deleting a key that doesn't exist should not throw
        XCTAssertNoThrow(try keychainService.delete(key: "nonexistentKey"))
    }
}
