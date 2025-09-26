//
//  CollectionAPI.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//

import Foundation

protocol CollectionAPI: Sendable {
    func getNumberOfItems() async throws -> Int
}

extension APIService: CollectionAPI {
    func getNumberOfItems() async throws -> Int {
        guard accessToken != nil, accessTokenSecret != nil else {
            throw AuthError.missingAccessToken
        }

        let folderId = "0" // 0 is the "All" folder
        let username = try await getUsername()
        let endpoint = "\(baseURL)/users/\(username)/collection/folders/\(folderId)"
        let request = try createRequest("GET", endpoint)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(endpoint)
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8)
            throw APIError.httpError(statusCode: httpResponse.statusCode,
                                     message: errorMessage)
        }

        do {
            let decoder = JSONDecoder()
            let folder = try decoder.decode(CollectionFolder.self, from: data)
            return folder.count
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

