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
    private var mockCredentialStore: MockCredentialStore!

    // MARK: - Setup/Teardown

    override func setUp() async throws {
        try await super.setUp()

        state = AuthState()
        mockOAuthService = MockOAuthService()
        mockCredentialStore = MockCredentialStore()

        sut = AuthInteractor(
            state: state,
            service: mockOAuthService,
            credentialStore: mockCredentialStore
        )
    }

    override func tearDown() async throws {
        sut = nil
        state = nil
        mockOAuthService = nil
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
        XCTAssertEqual(sut.accessToken_testAccessor, token)
        XCTAssertEqual(sut.accessTokenSecret_testAccessor, secret)
        XCTAssertEqual(mockCredentialStore.loadCredentialsCallCount, 1)
    }

    func testLoadExistingAuth_WithNoCredentials_UserRemainsUnauthenticated() async {
        // When
        await sut.loadExistingAuth()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(sut.accessToken_testAccessor)
        XCTAssertNil(sut.accessTokenSecret_testAccessor)
        XCTAssertEqual(mockCredentialStore.loadCredentialsCallCount, 1)
    }

    func testLoadExistingAuth_WhenKeychainThrowsError_UserRemainsUnauthenticated() async {
        // Given
        mockCredentialStore.shouldThrowOnLoad = true

        // When
        await sut.loadExistingAuth()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(sut.accessToken_testAccessor)
        XCTAssertNil(sut.accessTokenSecret_testAccessor)
        XCTAssertEqual(mockCredentialStore.loadCredentialsCallCount, 1)
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
        XCTAssertEqual(sut.accessToken_testAccessor, expectedToken)
        XCTAssertEqual(sut.accessTokenSecret_testAccessor, expectedSecret)
        XCTAssertNil(state.authError)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 1)
        XCTAssertEqual(mockCredentialStore.saveCredentialsCallCount, 1)
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
        XCTAssertNil(sut.accessToken_testAccessor)
        XCTAssertNil(sut.accessTokenSecret_testAccessor)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 0)
        XCTAssertEqual(mockCredentialStore.saveCredentialsCallCount, 0)
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
        XCTAssertNil(sut.accessToken_testAccessor)
        XCTAssertNil(sut.accessTokenSecret_testAccessor)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 0)
        XCTAssertEqual(mockCredentialStore.saveCredentialsCallCount, 0)
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
        XCTAssertNil(sut.accessToken_testAccessor)
        XCTAssertNil(sut.accessTokenSecret_testAccessor)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 1)
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
        let url = mockOAuthService.tokenURL
        await sut.setUpStateFetchingAccessToken(from: url)

        // Then
        XCTAssertFalse(state.isAuthenticating)
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(sut.accessToken_testAccessor)
        XCTAssertNil(sut.accessTokenSecret_testAccessor)
        XCTAssertNotNil(state.authError)
        XCTAssertEqual(mockOAuthService.getAccessTokenCallCount, 1)
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
        sut.accessToken_testAccessor = "test_token"
        sut.accessTokenSecret_testAccessor = "test_secret"

        // When
        await sut.signOut()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(sut.accessToken_testAccessor)
        XCTAssertNil(sut.accessTokenSecret_testAccessor)
        XCTAssertEqual(mockCredentialStore.clearCredentialsCallCount, 1)
    }

    func testSignOut_WhenKeychainThrowsError_StillClearsState() async {
        // Given
        mockCredentialStore.shouldThrowOnClear = true
        state.isAuthenticated = true
        sut.accessToken_testAccessor = "test_token"
        sut.accessTokenSecret_testAccessor = "test_secret"

        // When
        await sut.signOut()

        // Then
        XCTAssertFalse(state.isAuthenticated)
        XCTAssertNil(sut.accessToken_testAccessor)
        XCTAssertNil(sut.accessTokenSecret_testAccessor)
        XCTAssertEqual(mockCredentialStore.clearCredentialsCallCount, 1)
    }
}
