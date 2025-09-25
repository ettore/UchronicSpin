//
//  OAuthServiceTests.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 5/16/25.
//

import XCTest
@testable import Uchronic_Spin

final class OAuthServiceTests: XCTestCase {

    // MARK: - Properties

    private let testConsumerKey = "test_consumer_key"
    private let testConsumerSecret = "test_consumer_secret"
    private let testBaseURL = "https://test.api.com"

    // MARK: - Test Setup

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createSUT(mockSession: MockURLSession) -> APIService {
        APIService(
            consumerKey: testConsumerKey,
            consumerSecret: testConsumerSecret,
            baseURL: testBaseURL,
            urlSession: mockSession
        )
    }

    private func makeRequestTokenResponse() -> Data {
        "oauth_token=test_request_token&oauth_token_secret=test_request_secret".data(using: .utf8)!
    }

    private func makeAccessTokenResponse() -> Data {
        "oauth_token=test_access_token&oauth_token_secret=test_access_secret".data(using: .utf8)!
    }

    // MARK: - getAuthorizationURL Tests

    func testGetAuthorizationURL() {
        // Given
        let sut = createSUT(mockSession: MockURLSession(data: Data()))
        let testToken = "test_token"

        // When
        let url = sut.getAuthorizationURL(token: testToken)

        // Then
        XCTAssertEqual(url?.absoluteString, "https://discogs.com/oauth/authorize?oauth_token=test_token")
    }

    // MARK: - Request Token Tests

    func testGetRequestToken_Success() async throws {
        // Given
        let mockSession = MockURLSession(data: makeRequestTokenResponse())
        let sut = createSUT(mockSession: mockSession)

        // When
        let result = try await sut.getRequestToken()

        // Then
        XCTAssertEqual(result.token, "test_request_token")
        XCTAssertEqual(result.secret, "test_request_secret")

        // Verify request
        let capturedRequest = mockSession.capturedRequest
        XCTAssertEqual(capturedRequest?.url?.absoluteString, "\(testBaseURL)/oauth/request_token")
        XCTAssertEqual(capturedRequest?.httpMethod, "GET")

        // Verify authorization header contains all required OAuth parameters
        let authHeader = capturedRequest?.value(forHTTPHeaderField: "Authorization") ?? ""
        XCTAssertTrue(authHeader.contains("OAuth "))
        XCTAssertTrue(authHeader.contains("oauth_consumer_key=\"\(testConsumerKey)\""))
        XCTAssertTrue(authHeader.contains("oauth_signature_method=\"PLAINTEXT\""))
        XCTAssertTrue(authHeader.contains("oauth_signature=\"\(testConsumerSecret)&\""))
        XCTAssertTrue(authHeader.contains("oauth_callback=\"uchronicspin://oauth-callback\""))

        // Verify other headers
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "User-Agent"), USER_AGENT)
    }

    func testGetRequestToken_InvalidResponse() async {
        // Given
        let mockSession = MockURLSession(data: "invalid_response".data(using: .utf8)!)
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getRequestToken()
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            guard let error = error as? AuthError else {
                XCTFail("Unexpected \(error) error instead of AuthError")
                return
            }
            guard case .invalidRequestToken = error else {
                XCTFail("Unexpected \(error) instead of invalidRequestToken error")
                return
            }
        }
    }

    func testGetRequestToken_EmptyResponse() async {
        // Given
        let mockSession = MockURLSession(data: Data())
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getRequestToken()
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            guard let error = error as? AuthError else {
                XCTFail("Unexpected \(error) error instead of AuthError")
                return
            }
            guard case .invalidRequestToken = error else {
                XCTFail("Unexpected \(error) instead of invalidRequestToken error")
                return
            }
        }
    }

    func testGetRequestToken_MissingTokenInResponse() async {
        // Given
        let mockSession = MockURLSession(data: "oauth_token_secret=test_secret".data(using: .utf8)!)
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getRequestToken()
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            guard let error = error as? AuthError else {
                XCTFail("Unexpected \(error) error instead of AuthError")
                return
            }
            guard case .invalidRequestToken = error else {
                XCTFail("Unexpected \(error) instead of invalidRequestToken error")
                return
            }
        }
    }

    func testGetRequestToken_MissingSecretInResponse() async {
        // Given
        let mockSession = MockURLSession(data: "oauth_token=test_token".data(using: .utf8)!)
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getRequestToken()
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            guard let error = error as? AuthError else {
                XCTFail("Unexpected \(error) error instead of AuthError")
                return
            }
            guard case .invalidRequestToken = error else {
                XCTFail("Unexpected \(error) instead of invalidRequestToken error")
                return
            }
        }
    }

    func testGetRequestToken_EmptyToken() async {
        // Given
        let mockSession = MockURLSession(data: "oauth_token=&oauth_token_secret=test_secret".data(using: .utf8)!)
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getRequestToken()
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            guard let error = error as? AuthError else {
                XCTFail("Unexpected \(error) error instead of AuthError")
                return
            }
            guard case .invalidRequestToken = error else {
                XCTFail("Unexpected \(error) instead of invalidRequestToken error")
                return
            }
        }
    }

    func testGetRequestToken_NetworkError() async {
        // Given
        let networkError = NSError(domain: "NetworkError", code: 1001, userInfo: nil)
        let mockSession = MockURLSession(data: Data(), error: networkError)
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getRequestToken()
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            // The error should be passed through
            XCTAssertEqual((error as NSError).domain, "NetworkError")
            XCTAssertEqual((error as NSError).code, 1001)
        }
    }

    // MARK: - Access Token Tests

    func testGetAccessToken_Success() async throws {
        // Given
        let mockSession = MockURLSession(data: makeAccessTokenResponse())
        let sut = createSUT(mockSession: mockSession)
        let testRequestToken = "test_request_token"
        let testRequestSecret = "test_request_secret"
        let testVerifier = "test_verifier"

        // When
        let result = try await sut.getAccessToken(
            requestToken: testRequestToken,
            requestTokenSecret: testRequestSecret,
            verifier: testVerifier
        )

        // Then
        XCTAssertEqual(result.token, "test_access_token")
        XCTAssertEqual(result.secret, "test_access_secret")

        // Verify request
        let capturedRequest = mockSession.capturedRequest
        XCTAssertEqual(capturedRequest?.url?.absoluteString, "\(testBaseURL)/oauth/access_token")
        XCTAssertEqual(capturedRequest?.httpMethod, "POST")

        // Verify authorization header contains all required Access Token OAuth parameters
        let authHeader = capturedRequest?.value(forHTTPHeaderField: "Authorization") ?? ""
        XCTAssertTrue(authHeader.contains("OAuth "))
        XCTAssertTrue(authHeader.contains("oauth_consumer_key=\"\(testConsumerKey)\""))
        XCTAssertTrue(authHeader.contains("oauth_token=\"\(testRequestToken)\""))
        XCTAssertTrue(authHeader.contains("oauth_signature_method=\"PLAINTEXT\""))
        XCTAssertTrue(authHeader.contains("oauth_signature=\"\(testConsumerSecret)&\(testRequestSecret)\""))
        XCTAssertTrue(authHeader.contains("oauth_verifier=\"\(testVerifier)\""))
    }

    func testGetAccessToken_InvalidResponse() async {
        // Given
        let mockSession = MockURLSession(data: "invalid_response".data(using: .utf8)!)
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getAccessToken(
                requestToken: "test_token",
                requestTokenSecret: "test_secret",
                verifier: "test_verifier"
            )
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            guard let error = error as? AuthError else {
                XCTFail("Unexpected error type \(error) instead of AuthError")
                return
            }
            guard case .invalidAccessToken = error else {
                XCTFail("Unexpected \(error) instead of invalidAccessToken error")
                return
            }
        }
    }

    func testGetAccessToken_MissingToken() async {
        // Given
        let mockSession = MockURLSession(data: "oauth_token_secret=test_secret".data(using: .utf8)!)
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getAccessToken(
                requestToken: "test_token",
                requestTokenSecret: "test_secret",
                verifier: "test_verifier"
            )
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            guard let error = error as? AuthError else {
                XCTFail("Unexpected error type \(error) instead of AuthError")
                return
            }
            guard case .invalidAccessToken = error else {
                XCTFail("Unexpected \(error) instead of invalidAccessToken error")
                return
            }
        }
    }

    func testGetAccessToken_NetworkError() async {
        // Given
        let networkError = NSError(domain: "NetworkError", code: 1001, userInfo: nil)
        let mockSession = MockURLSession(data: Data(), error: networkError)
        let sut = createSUT(mockSession: mockSession)

        // When / Then
        do {
            _ = try await sut.getAccessToken(
                requestToken: "test_token",
                requestTokenSecret: "test_secret",
                verifier: "test_verifier"
            )
            XCTFail("Expected function to throw, but it didn't")
        } catch {
            // The error should be passed through
            XCTAssertEqual((error as NSError).domain, "NetworkError")
            XCTAssertEqual((error as NSError).code, 1001)
        }
    }
}
