//
//  AuthInteractorTests.swift
//  Uchronic SpinTests
//
//  Created on 5/15/25.
//

import XCTest
@testable import Uchronic_Spin

@MainActor
final class AuthInteractorTests: XCTestCase, @unchecked Sendable {

    // MARK: - Properties

    private var sut: AuthInteractor!
    private var state: AuthState!
    private var mockOAuthService: MockOAuthService!
    private var mockKeychainManager: MockAuthKeychainManager!

    // MARK: - Setup/Teardown

    override func setUp() async throws {
        try await super.setUp()

        state = AuthState()
        mockOAuthService = MockOAuthService()
        mockKeychainManager = MockAuthKeychainManager()

        sut = AuthInteractor(
            state: state,
            service: mockOAuthService,
            keychainManager: mockKeychainManager
        )
    }

    override func tearDown() async throws {
        sut = nil
        state = nil
        mockOAuthService = nil
        mockKeychainManager = nil

        try await super.tearDown()
    }

    // MARK: - Test loadExistingAuth

    func testLoadExistingAuth_WithValidCredentials_SetsUserAsAuthenticated() async {
        // Given
        let token = "test_token"
        let secret = "test_secret"
        mockKeychainManager.credentials = (token: token, secret: secret)

        // When
        await sut.loadExistingAuth()

        // Then
        XCTAssertTrue(state.isAuthenticated)
        XCTAssertEqual(state.accessToken, token)
        XCTAssertEqual(state.accessTokenSecret, secret)
        XCTAssertEqual(mockKeychainManager.loadCredentialsCallCount, 1)
    }

    func testLoadExistingAuth_WithNoCredentials_UserRemainsUnauthenticated() async {
        // When
        await sut.loadExistingAuth()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.accessToken)
        XCTAssertNil(state.accessTokenSecret)
        XCTAssertEqual(mockKeychainManager.loadCredentialsCallCount, 1)
    }

    func testLoadExistingAuth_WhenKeychainThrowsError_UserRemainsUnauthenticated() async {
        // Given
        mockKeychainManager.shouldThrowOnLoad = true

        // When
        await sut.loadExistingAuth()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.accessToken)
        XCTAssertNil(state.accessTokenSecret)
        XCTAssertEqual(mockKeychainManager.loadCredentialsCallCount, 1)
    }

    // MARK: - Test startAuth

    func testStartAuth_Success_SetsRequestTokenAndOpensURL() async {
        // When
        await sut.startAuth()

        // Then
        XCTAssertTrue(state.isAuthenticating)
        XCTAssertNil(state.authError)
        XCTAssertEqual(mockOAuthService.getRequestTokenCallCount, 1)
    }

    func testStartAuth_WhenServiceThrowsError_SetsAuthError() async {
        // Given
        mockOAuthService.shouldThrowOnRequestToken = true

        // When
        await sut.startAuth()

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertNotNil(state.authError)
        XCTAssertEqual(mockOAuthService.getRequestTokenCallCount, 1)
    }

    // MARK: - Test setUpStateFetchingAccessToken

    func testSetUpStateFetchingAccessToken_Success_SetsUserAsAuthenticated() async {
        // Given
        let expectedToken = mockOAuthService.accessTokenResponse.token
        let expectedSecret = mockOAuthService.accessTokenResponse.secret

        // First set up the request token
        await sut.startAuth()

        // When
        let url = mockOAuthService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertTrue(state.isAuthenticated)
        XCTAssertEqual(state.accessToken, expectedToken)
        XCTAssertEqual(state.accessTokenSecret, expectedSecret)
        XCTAssertNil(state.authError)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 1)
        XCTAssertEqual(mockKeychainManager.saveCredentialsCallCount, 1)
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
        XCTAssertNil(state.accessToken)
        XCTAssertNil(state.accessTokenSecret)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 0)
        XCTAssertEqual(mockKeychainManager.saveCredentialsCallCount, 0)
        guard case .invalidRequestToken = state.authError else {
            XCTFail("AuthError should be invalidRequestToken")
            return
        }
    }

    func testSetUpStateFetchingAccessToken_WithMissingRequestToken_SetsAuthError() async {
        // Given - Don't call startAuth() to set up request token

        // When
        let url = mockOAuthService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.accessToken)
        XCTAssertNil(state.accessTokenSecret)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 0)
        XCTAssertEqual(mockKeychainManager.saveCredentialsCallCount, 0)
        guard case .missingRequestToken = state.authError else {
            XCTFail("AuthError should be .missingRequestToken")
            return
        }
    }

    func testSetUpStateFetchingAccessToken_WhenServiceThrowsError_SetsAuthError() async {
        // Given
        mockOAuthService.shouldThrowOnAccessToken = true
        await sut.startAuth()

        // When
        let url = mockOAuthService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.accessToken)
        XCTAssertNil(state.accessTokenSecret)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 1)
        XCTAssertEqual(mockKeychainManager.saveCredentialsCallCount, 0)
        guard case .invalidAccessToken = state.authError else {
            XCTFail("AuthError should be .invalidAccessToken")
            return
        }
    }

    func testSetUpStateFetchingAccessToken_WhenKeychainThrowsError_SetsAuthError() async {
        // Given
        mockKeychainManager.shouldThrowOnSave = true
        await sut.startAuth()

        // When
        let url = mockOAuthService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.accessToken)
        XCTAssertNil(state.accessTokenSecret)
        XCTAssertNotNil(state.authError)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 1)
        XCTAssertEqual(mockKeychainManager.saveCredentialsCallCount, 1)
        guard case .keychainError(_) = state.authError else {
            XCTFail("AuthError should be .keychainError(<error>)")
            return
        }
    }

    // MARK: - Test signOut

    func testSignOut_Success_ClearsCredentialsAndState() async {
        // Given
        state.isAuthenticated = true
        state.accessToken = "test_token"
        state.accessTokenSecret = "test_secret"

        // When
        await sut.signOut()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.accessToken)
        XCTAssertNil(state.accessTokenSecret)
        XCTAssertEqual(mockKeychainManager.clearCredentialsCallCount, 1)
    }

    func testSignOut_WhenKeychainThrowsError_StillClearsState() async {
        // Given
        mockKeychainManager.shouldThrowOnClear = true
        state.isAuthenticated = true
        state.accessToken = "test_token"
        state.accessTokenSecret = "test_secret"

        // When
        await sut.signOut()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(state.accessToken)
        XCTAssertNil(state.accessTokenSecret)
        XCTAssertEqual(mockKeychainManager.clearCredentialsCallCount, 1)
    }
}
