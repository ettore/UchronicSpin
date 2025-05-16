//
//  MockURLSession.swift
//  Uchronic Spin
//  Created by Ettore Pasquini on 5/16/25.
//

import Foundation
import XCTest
@testable import Uchronic_Spin


final class MockURLSession: DataFetching, @unchecked Sendable {
    let data: Data
    let response: URLResponse
    let error: Error?
    var capturedRequest: URLRequest?

    init(data: Data,
         response: URLResponse = HTTPURLResponse(url: URL(string: "https://api.discogs.com")!,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)!,
         error: Error? = nil) {
        self.data = data
        self.response = response
        self.error = error
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequest = request

        if let error = error {
            throw error
        }

        return (data, response)
    }
}
