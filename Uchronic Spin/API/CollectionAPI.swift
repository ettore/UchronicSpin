//
//  CollectionAPI.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation


protocol CollectionAPI: Sendable {
    func getCollection(page: Int, forUser: String) async throws -> [APIRelease]
    func getUserMetadata() async throws -> (username: String, numberOfItems: Int)
}


extension APIService: CollectionAPI {
    func getCollection(page: Int, forUser username: String) async throws -> [APIRelease] {
        guard accessToken != nil, accessTokenSecret != nil else {
            throw AuthError.missingAccessToken
        }

        let endpoint = collectionEndpoint(forUser: username, page: page)
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
            let releasesWrapper = try decoder.decode(APIReleases.self, from: data)
            return releasesWrapper.releases
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func getUserMetadata() async throws -> (username: String, numberOfItems: Int) {
        guard accessToken != nil, accessTokenSecret != nil else {
            throw AuthError.missingAccessToken
        }

        let username = try await getUsername()
        let endpoint = collectionEndpointRoot(forUser: username)
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
            let folder = try decoder.decode(APIFolder.self, from: data)

            return (username: username, numberOfItems: folder.count)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Helpers

    func collectionEndpointRoot(forUser username: String) -> String {
        let folderId = "0" // 0 is the "All" folder
        return "\(baseURL)/users/\(username)/collection/folders/\(folderId)"
    }

    func collectionEndpoint(forUser username: String, page: Int) -> String {
        let root = collectionEndpointRoot(forUser: username)
        return "\(root)/releases?sort=artist&sort_order=asc&per_page=100&page=\(page)"
    }
}

