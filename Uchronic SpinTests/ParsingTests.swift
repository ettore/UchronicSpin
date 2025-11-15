//
//  ParsingTests.swift
//  Uchronic SpinTests
//
//  Created by Ettore Pasquini on 11/14/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import Testing
@testable import Uchronic_Spin


struct ParsingTests {
    let artistJSON = """
        {
            "name": "Afrika Bambaataa & Soulsonic Force",
            "anv": "Afrika Bambaataa & The Soul Sonic Force",
            "join": "Music By",
            "role": "",
            "tracks": "",
            "id": 2532,
            "resource_url": "https://api.discogs.com/artists/2532"
        }
        """

    let formatJSON = #"""
        {
            "name": "Vinyl",
            "qty": "1",
            "text": "Blue-Green labels",
            "descriptions": [
                "12\"",
                "33 ⅓ RPM",
                "Single",
                "Reissue",
                "Repress"
            ]
        }
        """#

    static let releaseJSON = #"""
        {
            "id": 1448397,
            "instance_id": 150588447,
            "date_added": "2015-12-17T21:41:20-08:00",
            "rating": 0,
            "basic_information": {
                "id": 1448397,
                "master_id": 19152,
                "master_url": "https://api.discogs.com/masters/19152",
                "resource_url": "https://api.discogs.com/releases/1448397",
                "thumb": "https://i.discogs.com/nnje_6msUrTPkDIWhQc46ucs0Q55E-ovpsLH1NHYT_s/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE0NDgz/OTctMTIyMDYyODg4/My5qcGVn.jpeg",
                "cover_image": "https://i.discogs.com/DxRxiX32d9prONi6SyfWsCeoAUgOnsWOh0V8q46C5YA/rs:fit/g:sm/q:90/h:500/w:497/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE0NDgz/OTctMTIyMDYyODg4/My5qcGVn.jpeg",
                "title": "Planet Rock",
                "year": 0,
                "formats": [
                    {
                        "name": "Vinyl",
                        "qty": "1",
                        "text": "Blue-Green labels",
                        "descriptions": [
                            "12\"",
                            "33 ⅓ RPM",
                            "Single",
                            "Reissue",
                            "Repress"
                        ]
                    }
                ],
                "labels": [
                    {
                        "name": "Tommy Boy",
                        "catno": "TB 823",
                        "entity_type": "1",
                        "entity_type_name": "Label",
                        "id": 26011,
                        "resource_url": "https://api.discogs.com/labels/26011"
                    }
                ],
                "artists": [
                    {
                        "name": "Afrika Bambaataa & Soulsonic Force",
                        "anv": "Afrika Bambaataa & The Soul Sonic Force",
                        "join": "Music By",
                        "role": "",
                        "tracks": "",
                        "id": 2532,
                        "resource_url": "https://api.discogs.com/artists/2532"
                    },
                    {
                        "name": "Planet Patrol",
                        "anv": "",
                        "join": "",
                        "role": "",
                        "tracks": "",
                        "id": 3860,
                        "resource_url": "https://api.discogs.com/artists/3860"
                    }
                ],
                "genres": [
                    "Electronic",
                    "Hip Hop"
                ],
                "styles": [
                    "Electro",
                    "Breaks"
                ]
            },
            "notes": [
                {
                    "field_id": 1,
                    "value": "Very Good Plus (VG+)"
                },
                {
                    "field_id": 2,
                    "value": "Generic"
                }
            ]
        }
        """#

    let releasesJSON = """
        {
            "pagination": {
                "page": 15,
                "pages": 1490,
                "per_page": 1,
                "items": 1490,
                "urls": {
                    "first": "https://api.discogs.com/users/cubelogic/collection/folders/0/releases?page=1&per_page=1&sort=artist&sort_order=asc",
                    "last": "https://api.discogs.com/users/cubelogic/collection/folders/0/releases?page=1490&per_page=1&sort=artist&sort_order=asc",
                    "prev": "https://api.discogs.com/users/cubelogic/collection/folders/0/releases?page=14&per_page=1&sort=artist&sort_order=asc",
                    "next": "https://api.discogs.com/users/cubelogic/collection/folders/0/releases?page=16&per_page=1&sort=artist&sort_order=asc"
                }
            },
            "releases": [
                \(ParsingTests.releaseJSON)
            ]
        }
        """

    @Test func testArtist() async throws {
        let data = artistJSON.data(using: .utf8)!
        let artist = try JSONDecoder().decode(APIArtist.self, from: data)
        #expect(artist.id == "2532")
        #expect(artist.name == "Afrika Bambaataa & Soulsonic Force")
        #expect(artist.anv == "Afrika Bambaataa & The Soul Sonic Force")
        #expect(artist.role == nil)
        #expect(artist.resourceURL == URL(string: "https://api.discogs.com/artists/2532")!)
    }

    @Test func testFormat() async throws {
        let data = formatJSON.data(using: .utf8)!
        let format = try JSONDecoder().decode(APIFormat.self, from: data)
        #expect(format.name == "Vinyl")
        #expect(format.quantity == "1")
        #expect(format.descriptions.count == 5)
        #expect(format.descriptions[0] == "12\"")
        #expect(format.descriptions[1] == "33 ⅓ RPM")
        #expect(format.descriptions[2] == "Single")
        #expect(format.descriptions[3] == "Reissue")
        #expect(format.descriptions[4] == "Repress")
    }

    @Test func testRelease() async throws {
        let data = ParsingTests.releaseJSON.data(using: .utf8)!
        let release = try JSONDecoder().decode(APIRelease.self, from: data)

        #expect(release.id == "1448397")
        #expect(release.rating == 0)
        #expect(release.url == URL(string: "https://api.discogs.com/releases/1448397")!)
        #expect(release.masterId == "19152")
        #expect(release.masterURL != nil)
        #expect(release.masterURL == URL(string: "https://api.discogs.com/masters/19152"))
        #expect(release.thumbURL == URL(string: "https://i.discogs.com/nnje_6msUrTPkDIWhQc46ucs0Q55E-ovpsLH1NHYT_s/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE0NDgz/OTctMTIyMDYyODg4/My5qcGVn.jpeg"))
        #expect(release.coverURL == URL(string: "https://i.discogs.com/DxRxiX32d9prONi6SyfWsCeoAUgOnsWOh0V8q46C5YA/rs:fit/g:sm/q:90/h:500/w:497/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE0NDgz/OTctMTIyMDYyODg4/My5qcGVn.jpeg"))
        #expect(release.title == "Planet Rock")
        #expect(release.year == nil)
        #expect(release.formats.count == 1)
        #expect(release.formats[0].name == "Vinyl")
        #expect(release.artists.count == 2)
        #expect(release.artists[0].name == "Afrika Bambaataa & Soulsonic Force")
        #expect(release.artists[1].name == "Planet Patrol")
        #expect(release.genres == ["Electronic", "Hip Hop"])
        #expect(release.styles == ["Electro", "Breaks"])
    }

    @Test func testReleaseArray() async throws {
        let data = releasesJSON.data(using: .utf8)!
        let releasesWrapper = try JSONDecoder().decode(APIReleases.self, from: data)
        let releases = releasesWrapper.releases

        #expect(releases.count == 1)
        let firstRelease = releases.first!
        #expect(firstRelease.id == "1448397")
        #expect(firstRelease.masterId == "19152")
        #expect(firstRelease.formats.count == 1)
        #expect(firstRelease.formats[0].name == "Vinyl")
        #expect(firstRelease.artists.count == 2)
        #expect(firstRelease.artists[0].name == "Afrika Bambaataa & Soulsonic Force")
        #expect(firstRelease.artists[1].name == "Planet Patrol")
        #expect(firstRelease.genres == ["Electronic", "Hip Hop"])
        #expect(firstRelease.styles == ["Electro", "Breaks"])
    }
}
