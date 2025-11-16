//
//  CollectionAPI.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation


protocol CollectionAPI: Sendable {
    func getCollection(forUser: String,
                       withMaxConcurrency maxConcurrency: Int,
                       numberOfItems: Int) async -> (releases: [APIRelease],
                                                     failedPages: Set<Int>)

    func getUserMetadata() async throws -> (username: String, numberOfItems: Int)
}

extension CollectionAPI {
    func getCollection(forUser username: String,
                       numberOfItems numItems: Int) async -> (releases: [APIRelease],
                                                              failedPages: Set<Int>) {
        await getCollection(forUser: username,
                            withMaxConcurrency: 3,
                            numberOfItems: numItems)
    }
}

private let perPage: Int = 100


extension APIService: CollectionAPI {

    /// Fetch the entire collection for the given user.
    ///
    /// - Parameters:
    ///   - username: The user's whose collection we want to get.
    ///   - maxConcurrency: Max number of concurrent requests. This is capped
    ///   between 1 and 6.
    ///   - perPage: Number of items in a single page. This is capped
    ///   between 1 and 100.
    ///   - numberOfItems: The total number of items to fetch.
    /// - Returns: A tuple with an array of releases in the user's collection
    /// in pagination order, and the pages whose requests failed.
    func getCollection(forUser username: String,
                       withMaxConcurrency maxConcurrency: Int,
                       numberOfItems: Int) async -> (releases: [APIRelease],
                                                     failedPages: Set<Int>) {
        let perPage = max(1, min(100, perPage))
        let totalPages = Int(ceil(Double(numberOfItems) / Double(perPage)))
        let actualMaxConcurrency = min(6, max(1, min(totalPages, maxConcurrency)))

        if actualMaxConcurrency == 1 {
            return await getCollection(forUser: username,
                                       perPage: perPage,
                                       totalPages: totalPages)
        } else {
            return await getCollection(forUser: username,
                                       withMaxConcurrency: actualMaxConcurrency,
                                       perPage: perPage,
                                       totalPages: totalPages)
        }
    }

    /// Fetch the entire collection for the given user by issuing page
    /// requests concurrently.
    ///
    /// - Parameters:
    ///   - username: The user's whose collection we want to get.
    ///   - maxConcurrency: Max number of concurrent requests (uncapped).
    ///   - perPage: Number of items in a single page. This must be
    ///   between 1 and 100.
    ///   - totalPages: The total number of pages to fetch.
    /// - Returns: A tuple with an array of releases in the user's collection
    /// in pagination order, and the pages whose requests failed.
    private func getCollection(forUser username: String,
                               withMaxConcurrency maxConcurrency: Int,
                               perPage: Int = perPage,
                               totalPages: Int) async -> (releases: [APIRelease],
                                                          failedPages: Set<Int>) {

        var apiReleases = [Int: [APIRelease]]()
        var failedPages: Set<Int> = []
        var nextPage = 1

        return await withTaskGroup(of: (page: Int,
                                        releases: [APIRelease],
                                        failedPages: Set<Int>).self) { group in
            // start by adding a throttled number of tasks to the group
            for page in 1...min(maxConcurrency, totalPages) {
                group.addTask {
                    do {
                        let releases = try await self.getCollection(page: page,
                                                                    forUser: username)
                        return (page: page, releases: releases, failedPages: [])
                    } catch {
                        return (page: page, releases: [], failedPages: [page])
                    }
                }
                nextPage += 1
            }

            // we then wait for one task to complete, and once that happens
            // we add the results to the `apiReleases` array, then issue a
            // new page request
            for await pageResults in group {
                apiReleases[pageResults.page] = pageResults.releases
                failedPages.formUnion(pageResults.failedPages)

                if nextPage <= totalPages {
                    group.addTask { [nextPage] in
                        do {
                            let releases = try await self.getCollection(page: nextPage,
                                                                        forUser: username)
                            return (page: nextPage, releases: releases, failedPages: [])
                        } catch {
                            return (page: nextPage, releases: [], failedPages: [nextPage])
                        }
                    }
                    nextPage += 1
                }
            }

            // retry failed pages one more time
            await retry(failedPages: &failedPages,
                        apiReleases: &apiReleases,
                        forUser: username,
                        perPage: perPage)

            // flatten everything in page order
            let allReleases = (1...totalPages).flatMap { apiReleases[$0] ?? [] }

            return (allReleases, failedPages)
        }
    }

    /// Fetch the entire collection for the given user by sequentially issuing
    /// one request at a time.
    ///
    /// - Parameters:
    ///   - username: The user's whose collection we want to get.
    ///   - perPage: Number of items in a single page. This must be
    ///   between 1 and 100.
    ///   - totalPages: The total number of pages to fetch.
    /// - Returns: A tuple with an array of releases in the user's collection
    /// in pagination order, and the pages whose requests failed.
    private func getCollection(forUser username: String,
                               perPage: Int = perPage,
                               totalPages: Int) async -> (releases: [APIRelease],
                                                          failedPages: Set<Int>) {
        var apiReleases = [Int: [APIRelease]]()
        var failedPages: Set<Int> = []

        for page in 1...totalPages {
            do {
                let releases = try await getCollection(page: page, forUser: username)
                apiReleases[page] = releases
            } catch {
                failedPages.insert(page)
            }
        }

        await retry(failedPages: &failedPages, apiReleases: &apiReleases,
                    forUser: username, perPage: perPage)

        let allReleases = (1...totalPages).flatMap { apiReleases[$0] ?? [] }
        return (allReleases, failedPages)
    }

    func retry(failedPages: inout Set<Int>,
               apiReleases: inout [Int: [APIRelease]],
               forUser username: String,
               perPage: Int = perPage) async {
        for page in failedPages {
            if let releases = try? await getCollection(page: page,
                                                       forUser: username) {
                apiReleases[page] = releases
                failedPages.remove(page)
            }
        }
    }

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
        return "\(root)/releases?sort=artist&sort_order=asc&per_page=\(perPage)&page=\(page)"
    }
}

