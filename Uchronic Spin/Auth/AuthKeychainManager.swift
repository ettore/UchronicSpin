//
//  AuthKeychainManaging.swift
//  Uchronic Spin
//  Created by Ettore Pasquini on 5/14/25.
//


import Foundation

protocol AuthKeychainManaging: Sendable {
    func saveCredentials(token: String, secret: String) async throws
    func loadCredentials() async throws -> (token: String, secret: String)?
    func clearCredentials() async throws
}

actor AuthKeychainManager: AuthKeychainManaging {
    private let keychainService: KeychainServicing
    private let tokenKey = "auth.accessToken"
    private let secretKey = "auth.accessTokenSecret"

    init(keychainService: KeychainServicing = KeychainService()) {
        self.keychainService = keychainService
    }

    func saveCredentials(token: String, secret: String) async throws {
        guard let tokenData = token.data(using: .utf8),
              let secretData = secret.data(using: .utf8) else {
            throw KeychainError.wrongDataFormat
        }

        try keychainService.save(key: tokenKey, data: tokenData)
        try keychainService.save(key: secretKey, data: secretData)
    }

    func loadCredentials() async throws -> (token: String, secret: String)? {
        do {
            let tokenData = try keychainService.load(key: tokenKey)
            let secretData = try keychainService.load(key: secretKey)

            guard let token = String(data: tokenData, encoding: .utf8),
                  let secret = String(data: secretData, encoding: .utf8) else {
                throw KeychainError.wrongDataFormat
            }

            return (token, secret)
        } catch KeychainError.itemNotFound {
            // Not finding credentials is not an error, just return nil
            return nil
        }
    }

    func clearCredentials() async throws {
        try keychainService.delete(key: tokenKey)
        try keychainService.delete(key: secretKey)
    }
}
