//
//  AuthInteractorTests.swift
//  Uchronic SpinTests
//
//  Created on 5/15/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import XCTest
@testable import Uchronic_Spin


@MainActor
final class AuthInteractorTests: XCTestCase, @unchecked Sendable {

    // MARK: - Properties

    private var sut: AuthInteractor!
    private var state: AuthState!
    private var mockAPIService: MockOAuthService!
    private var apiService: APIService!
    private var mockCredentialStore: MockCredentialStore!

    // MARK: - Setup/Teardown

    override func setUp() async throws {
        try await super.setUp()

        let modelContext = MockModelContext()
        state = AuthState(modelContext: modelContext)
        mockAPIService = MockOAuthService()
        mockCredentialStore = MockCredentialStore()

        sut = AuthInteractor(
            state: state,
            apiService: mockAPIService,
            credentialStore: mockCredentialStore,
            log: MockLog()
        )
    }

    override func tearDown() async throws {
        sut = nil
        state = nil
        apiService = nil
        mockCredentialStore = nil

        try await super.tearDown()
    }

    // MARK: - Test loadExistingAuth

    func testLoadExistingAuth_WithValidCredentials_SetsUserAsAuthenticated() async {
        // Given
        let token = "test_token"
        let secret = "test_secret"
        mockCredentialStore.credentials = (token: token, secret: secret)

        // When
        await sut.loadExistingAuth()

        // Then
        XCTAssertTrue(state.isAuthenticated)
        XCTAssertEqual(mockAPIService.accessToken, token)
        XCTAssertEqual(mockAPIService.accessTokenSecret, secret)
        XCTAssertEqual(mockAPIService.setNonNilAccessCredentialsCallCount, 1)
        XCTAssertEqual(mockCredentialStore.loadCredentialsCallCount, 1)
    }

    func testLoadExistingAuth_WithNoCredentials_UserRemainsUnauthenticated() async {
        // When
        await sut.loadExistingAuth()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(mockAPIService.accessToken)
        XCTAssertNil(mockAPIService.accessTokenSecret)
        XCTAssertEqual(mockAPIService.setNonNilAccessCredentialsCallCount, 0)
        XCTAssertEqual(mockCredentialStore.loadCredentialsCallCount, 1)
    }

    func testLoadExistingAuth_WhenKeychainThrowsError_UserRemainsUnauthenticated() async {
        // Given
        mockCredentialStore.shouldThrowOnLoad = true

        // When
        await sut.loadExistingAuth()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(mockAPIService.accessToken)
        XCTAssertNil(mockAPIService.accessTokenSecret)
        XCTAssertEqual(mockAPIService.setNonNilAccessCredentialsCallCount, 0)
        XCTAssertEqual(mockCredentialStore.loadCredentialsCallCount, 1)
    }

    // MARK: - Test startAuth

    func testStartAuth_Success_SetsRequestTokenAndOpensURL() async {
        // When
        await sut.startAuth()

        // Then
        XCTAssertTrue(state.isAuthenticating)
        XCTAssertNil(state.authError)
        XCTAssertEqual(mockAPIService.getRequestTokenCallCount, 1)
    }

    func testStartAuth_WhenServiceThrowsError_SetsAuthError() async {
        // Given
        mockAPIService.shouldThrowOnRequestToken = true

        // When
        await sut.startAuth()

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertNotNil(state.authError)
        XCTAssertEqual(mockAPIService.getRequestTokenCallCount, 1)
    }

    // MARK: - Test setUpStateFetchingAccessToken

    func testSetUpStateFetchingAccessToken_Success_SetsUserAsAuthenticated() async {
        // Given
        let expectedToken = mockAPIService.accessTokenResponse.token
        let expectedSecret = mockAPIService.accessTokenResponse.secret

        // First set up the request token
        await sut.startAuth()

        // When
        let url = mockAPIService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertTrue(state.isAuthenticated)
        XCTAssertEqual(mockAPIService.accessToken, expectedToken)
        XCTAssertEqual(mockAPIService.accessTokenSecret, expectedSecret)
        XCTAssertNil(state.authError)
        XCTAssertEqual(mockAPIService.getAccessTokenCallCount, 1)
        XCTAssertEqual(mockCredentialStore.saveCredentialsCallCount, 1)
        XCTAssertEqual(mockAPIService.setNonNilAccessCredentialsCallCount, 1)
        XCTAssertEqual(mockAPIService.resetAccessCredentialsCallCount, 0)
    }

    func testSetUpStateFetchingAccessToken_WithMissingVerifier_SetsAuthError() async {
        // Given
        await sut.startAuth()

        // When - URL without a verifier
        let url = URL(string: "https://example.com/callback")!
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(mockAPIService.accessToken)
        XCTAssertNil(mockAPIService.accessTokenSecret)
        XCTAssertEqual(mockAPIService.getAccessTokenCallCount, 0)
        XCTAssertEqual(mockAPIService.setNonNilAccessCredentialsCallCount, 0)
        XCTAssertEqual(mockCredentialStore.saveCredentialsCallCount, 0)
        guard case .invalidRequestToken = state.authError else {
            XCTFail("AuthError should be invalidRequestToken")
            return
        }
    }

    func testSetUpStateFetchingAccessToken_WithMissingRequestToken_SetsAuthError() async {
        // Given - Don't call startAuth() to set up request token

        // When
        let url = mockAPIService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(mockAPIService.accessToken)
        XCTAssertNil(mockAPIService.accessTokenSecret)
        XCTAssertEqual(mockAPIService.getAccessTokenCallCount, 0)
        XCTAssertEqual(mockAPIService.setNonNilAccessCredentialsCallCount, 0)
        XCTAssertEqual(mockCredentialStore.saveCredentialsCallCount, 0)
        guard case .missingRequestToken = state.authError else {
            XCTFail("AuthError should be .missingRequestToken")
            return
        }
    }

    func testSetUpStateFetchingAccessToken_WhenServiceThrowsError_SetsAuthError() async {
        // Given
        mockAPIService.shouldThrowOnAccessToken = true
        await sut.startAuth()

        // When
        let url = mockAPIService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(mockAPIService.accessToken)
        XCTAssertNil(mockAPIService.accessTokenSecret)
        XCTAssertEqual(mockAPIService.getAccessTokenCallCount, 1)
        XCTAssertEqual(mockAPIService.setNonNilAccessCredentialsCallCount, 0)
        XCTAssertEqual(mockCredentialStore.saveCredentialsCallCount, 0)
        guard case .invalidAccessToken = state.authError else {
            XCTFail("AuthError should be .invalidAccessToken")
            return
        }
    }

    func testSetUpStateFetchingAccessToken_WhenKeychainThrowsError_SetsAuthError() async {
        // Given
        mockCredentialStore.shouldThrowOnSave = true
        await sut.startAuth()

        // When
        let url = mockAPIService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(mockAPIService.accessToken)
        XCTAssertNil(mockAPIService.accessTokenSecret)
        XCTAssertEqual(mockAPIService.getAccessTokenCallCount, 1)
        XCTAssertEqual(mockAPIService.setNonNilAccessCredentialsCallCount, 0)
        XCTAssertNotNil(state.authError)
        XCTAssertEqual(mockAPIService.getAccessTokenCallCount, 1)
        XCTAssertEqual(mockCredentialStore.saveCredentialsCallCount, 1)
        guard case .keychainError(_) = state.authError else {
            XCTFail("AuthError should be .keychainError(<error>)")
            return
        }
    }

    // MARK: - Test signOut

    func testSignOut_Success_ClearsCredentialsAndState() async {
        // Given
        state.isAuthenticated = true
        mockAPIService.accessToken = "test_token"
        mockAPIService.accessTokenSecret = "test_secret"

        // When
        await sut.signOut()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(mockAPIService.accessToken)
        XCTAssertNil(mockAPIService.accessTokenSecret)
        XCTAssertEqual(mockAPIService.resetAccessCredentialsCallCount, 1)
        XCTAssertEqual(mockCredentialStore.clearCredentialsCallCount, 1)
    }

    func testSignOut_WhenKeychainThrowsError_StillClearsState() async {
        // Given
        mockCredentialStore.shouldThrowOnClear = true
        state.isAuthenticated = true
        mockAPIService.accessToken = "test_token"
        mockAPIService.accessTokenSecret = "test_secret"

        // When
        await sut.signOut()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(mockAPIService.accessToken)
        XCTAssertNil(mockAPIService.accessTokenSecret)
        XCTAssertEqual(mockAPIService.resetAccessCredentialsCallCount, 1)
        XCTAssertEqual(mockCredentialStore.clearCredentialsCallCount, 1)
    }
}
