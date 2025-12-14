//
//  MockURLSession.swift
//  Uchronic Spin
//  Created by Ettore Pasquini on 5/16/25.
//

import Foundation
import XCTest
@testable import Uchronic_Spin


final class MockURLSession: DataFetching, @unchecked Sendable {
    private let singleRequest = URLRequest(url: URL(string: "http://example.org")!)

    // indexed by URLRequest::hashValue
    var traffic: [Int: (Data, URLResponse)]
    let error: Error?
    var capturedRequest: URLRequest?

    /// Use this in tests where your code is going to issue a single request,
    /// and therefore expect a single response.
    init(singleData: Data,
         singleResponse: URLResponse = HTTPURLResponse(
            url: URL(string: "https://api.discogs.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!,
         error: Error? = nil) {
        self.traffic = [singleRequest.hashValue: (singleData, singleResponse)]
        self.error = error
    }

    /// Use this initializer when you are testing more complex network traffic.
    init(traffic: [Int: (Data, URLResponse)] = [:],
         error: Error? = nil) {
        self.traffic = traffic
        self.error = error
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequest = request

        if let error = error {
            throw error
        }

        if let responseInfo = traffic[request.hashValue] {
            return responseInfo
        } else if let responseInfo = traffic[singleRequest.hashValue] {
            return responseInfo
        } else {
            fatalError("Error in setting of MockURLSession")
        }
    }
}
