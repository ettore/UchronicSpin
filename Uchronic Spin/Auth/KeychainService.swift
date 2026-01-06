//
//  KeychainService.swift
//  Uchronic Spin
//  Created by Ettore Pasquini on 5/13/25.
//

import Foundation
import Security

enum KeychainError: Error {
    case saveFailure(OSStatus)
    case loadFailure(OSStatus)
    case deleteFailure(OSStatus)
    case itemNotFound
    case wrongDataFormat
}

protocol KeychainServicing: Sendable {
    func save(key: String, data: Data) throws
    func load(key: String) throws -> Data
    func delete(key: String) throws
}

final class KeychainService: KeychainServicing {
    private let serviceName: String

    /// Designated initializer.
    ///
    /// - Parameter serviceName: The name of the service for the keychain
    /// item to be stored.
    init(serviceName: String) {
        self.serviceName = serviceName
    }

    func save(key: String, data: Data) throws {
        // Create query dictionary
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecValueData: data
        ]

        // First attempt to delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add the item to the keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailure(status)
        }
    }

    func load(key: String) throws -> Data {
        // Create query dictionary
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        // Query the keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.loadFailure(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.wrongDataFormat
        }

        return data
    }

    func delete(key: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailure(status)
        }
    }
}
