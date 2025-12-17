//
//  CollectionAPI.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation


private let PER_PAGE: Int = 100


protocol CollectionAPI: Sendable {
    func getCollection(forUser: String,
                       withMaxConcurrency maxConcurrency: Int,
                       numberOfItems: Int,
                       perPage: Int) async -> APIPaginatedCollection

    func getUserMetadata() async throws -> (username: String, numberOfItems: Int)
}


extension CollectionAPI {
    func getCollection(forUser username: String,
                       numberOfItems: Int,
                       perPage: Int = PER_PAGE) async -> APIPaginatedCollection {
        await getCollection(forUser: username,
                            withMaxConcurrency: 3,
                            numberOfItems: numberOfItems,
                            perPage: perPage)
    }
}


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
    /// - Returns: The user's paginated collection.
    func getCollection(forUser username: String,
                       withMaxConcurrency maxConcurrency: Int,
                       numberOfItems: Int,
                       perPage: Int) async -> APIPaginatedCollection {
        let perPage = max(1, min(100, perPage))
        let totalPages = Int(ceil(Double(numberOfItems) / Double(perPage)))
        let actualMaxConcurrency = min(6, max(1, min(totalPages, maxConcurrency)))

        if actualMaxConcurrency == 1 {
            return await getCollection(forUser: username,
                                       totalPages: totalPages,
                                       perPage: perPage)
        } else {
            return await getCollection(forUser: username,
                                       withMaxConcurrency: actualMaxConcurrency,
                                       totalPages: totalPages,
                                       perPage: perPage)
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
    /// - Returns: The user's paginated collection.
    private func getCollection(forUser username: String,
                               withMaxConcurrency maxConcurrency: Int,
                               totalPages: Int,
                               perPage: Int) async -> APIPaginatedCollection {

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
                                                                    forUser: username,
                                                                    perPage: perPage)
                        return (page: page, releases: releases, failedPages: [])
                    } catch {
                        return (page: page, releases: [], failedPages: [page])
                    }
                }
                nextPage += 1
            }

            // we then wait for all the added tasks to complete, and then
            // we add the results to the `apiReleases` array, then issue
            // new page requests
            // TODO: instead of waiting for all tasks to complete, add a task
            //       as soon as one completes (maybe use `group.next()`?)
            for await pageResults in group {
                // one loop iteration for every task we had added to `group`
                apiReleases[pageResults.page] = pageResults.releases
                failedPages.formUnion(pageResults.failedPages)

                if nextPage <= totalPages {
                    group.addTask { [nextPage] in
                        do {
                            let releases = try await self.getCollection(page: nextPage,
                                                                        forUser: username,
                                                                        perPage: perPage)
                            return (page: nextPage, releases: releases, failedPages: [])
                        } catch {
                            return (page: nextPage, releases: [], failedPages: [nextPage])
                        }
                    }
                    nextPage += 1
                }
            }

            var collection = APIPaginatedCollection(pagedReleases: apiReleases,
                                                    failedPages: failedPages,
                                                    totalPages: totalPages,
                                                    perPage: perPage,
                                                    username: username)

            // retry failed pages one more time
            await retry(failedPagesFor: &collection, perPage: perPage)

            return collection
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
    /// - Returns: The user's paginated collection.
    private func getCollection(forUser username: String,
                               totalPages: Int,
                               perPage: Int) async -> APIPaginatedCollection {
        var apiReleases = [Int: [APIRelease]]()
        var failedPages: Set<Int> = []

        for page in 1...totalPages {
            do {
                let releases = try await getCollection(page: page, forUser: username, perPage: perPage)
                apiReleases[page] = releases
            } catch {
                failedPages.insert(page)
            }
        }

        var collection = APIPaginatedCollection(pagedReleases: apiReleases,
                                                failedPages: failedPages,
                                                totalPages: totalPages,
                                                perPage: perPage,
                                                username: username)

        await retry(failedPagesFor: &collection, perPage: perPage)

        return collection
    }

    /// Retries fetching the given failed pages in a given paginated collection,
    /// appending any new results to the same collection.
    ///
    /// - Parameters:
    ///   - collection: The collection for which to attempt to refetch its
    ///   failed pages.
    func retry(failedPagesFor collection: inout APIPaginatedCollection,
               perPage: Int) async {
        log.info("Retrying pages [\(collection.failedPages)]...")
        for page in collection.failedPages {
            if let releases = try? await getCollection(page: page,
                                                       forUser: collection.username,
                                                       perPage: perPage) {
                collection.pagedReleases[page] = releases
                collection.failedPages.remove(page)
            }
        }
    }

    private func getCollection(page: Int,
                               forUser username: String,
                               perPage: Int) async throws -> [APIRelease] {
        log.debug("Attempting to fetch page \(page)...")
        guard accessToken != nil, accessTokenSecret != nil else {
            throw AuthError.missingAccessToken
        }

        let endpoint = collectionEndpoint(forUser: username, page: page, perPage: perPage)
        let request = try createRequest("GET", endpoint)
        log.info("Fetching page \(page)...")
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

    func collectionEndpoint(forUser username: String, page: Int, perPage: Int) -> String {
        let root = collectionEndpointRoot(forUser: username)
        return "\(root)/releases?sort=artist&sort_order=asc&per_page=\(perPage)&page=\(page)"
    }
}

