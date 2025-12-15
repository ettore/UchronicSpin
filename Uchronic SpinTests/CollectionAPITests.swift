//
//  CollectionAPITests.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 11/16/25.
//  Copyright © 2025 Ettore Pasquini. All rights reserved.
//

import Foundation
import Testing
@testable import Uchronic_Spin

struct CollectionAPITests {
    private let testConsumerKey = "test_consumer_key"
    private let testConsumerSecret = "test_consumer_secret"
    private let testBaseURL = "https://test.example.com"

    static let release1 = #"""
            {
              "id": 7676896,
              "instance_id": 145849303,
              "date_added": "2015-11-02T23:20:13-08:00",
              "rating": 0,
              "basic_information": {
                "id": 7676896,
                "master_id": 0,
                "master_url": null,
                "resource_url": "https://api.discogs.com/releases/7676896",
                "thumb": "https://i.discogs.com/BldZAqchbjVhrSaC-37Ou7wuAE6vCiJqdeqO8XD2AMA/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTc2NzY4/OTYtMTQ0NjUwNjM0/OC00MjQ4LmpwZWc.jpeg",
                "cover_image": "https://i.discogs.com/9uAogstF75UJxEhch2kagldxjaBYwetNjD5KV-CNPeA/rs:fit/g:sm/q:90/h:600/w:600/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTc2NzY4/OTYtMTQ0NjUwNjM0/OC00MjQ4LmpwZWc.jpeg",
                "title": "Love Is Blue / The Shadow Of Your Smile",
                "year": 0,
                "formats": [{
                  "name": "Vinyl",
                  "qty": "1",
                  "descriptions": ["7\"", "45 RPM"]
                }],
                "labels": [{
                  "name": "Bluebell Record",
                  "catno": "BB. 3200",
                  "entity_type": "1",
                  "entity_type_name": "Label",
                  "id": 100387,
                  "resource_url": "https://api.discogs.com/labels/100387"
                }],
                "artists": [{
                  "name": "101 Strings",
                  "anv": "",
                  "join": "",
                  "role": "",
                  "tracks": "",
                  "id": 22041,
                  "resource_url": "https://api.discogs.com/artists/22041"
                }],
                "genres": ["Folk, World, & Country"],
                "styles": []
              }
            }
        """#

    static let release2 = #"""
            {
              "id": 7734706,
              "instance_id": 200303139,
              "date_added": "2016-12-02T04:51:18-08:00",
              "rating": 0,
              "basic_information": {
                "id": 7734706,
                "master_id": 54808,
                "master_url": "https://api.discogs.com/masters/54808",
                "resource_url": "https://api.discogs.com/releases/7734706",
                "thumb": "https://i.discogs.com/OAOUKfXLEZjvHrUylFFrH6WlIE6ZiOlTfw1je6u_WD4/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTc3MzQ3/MDYtMTQ0OTE3NTI5/OS04MTE3LmpwZWc.jpeg",
                "cover_image": "https://i.discogs.com/sTDWdl4FtVwa2eeZ3rBWCuyQj2J8ziqI7dsH59Mol-8/rs:fit/g:sm/q:90/h:500/w:500/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTc3MzQ3/MDYtMTQ0OTE3NTI5/OS04MTE3LmpwZWc.jpeg",
                "title": "The Psychedelic Sounds Of The 13th Floor Elevators",
                "year": 2015,
                "formats": [{
                  "name": "Vinyl",
                  "qty": "1",
                  "text": "Red Vinyl",
                  "descriptions": ["LP", "Album", "Reissue", "Stereo"]
                }],
                "labels": [{
                  "name": "International Artists",
                  "catno": "IA-LP-1",
                  "entity_type": "1",
                  "entity_type_name": "Label",
                  "id": 33286,
                  "resource_url": "https://api.discogs.com/labels/33286"
                }],
                "artists": [{
                  "name": "13th Floor Elevators",
                  "anv": "The 13th Floor Elevators",
                  "join": "",
                  "role": "",
                  "tracks": "",
                  "id": 304455,
                  "resource_url": "https://api.discogs.com/artists/304455"
                }],
                "genres": ["Rock"],
                "styles": ["Garage Rock", "Psychedelic Rock"]
              },
              "notes": [{
                "field_id": 1,
                "value": "Near Mint (NM or M-)"
              }, {
                "field_id": 2,
                "value": "Near Mint (NM or M-)"
              }]
            }
        """#

    static let release3 = #"""
            {
              "id": 442736,
              "instance_id": 163897664,
              "date_added": "2016-03-20T07:41:45-07:00",
              "rating": 0,
              "basic_information": {
                "id": 442736,
                "master_id": 959571,
                "master_url": "https://api.discogs.com/masters/959571",
                "resource_url": "https://api.discogs.com/releases/442736",
                "thumb": "https://i.discogs.com/5TyiVDrDwzcPsAq6LNWBcJbMmxH-8KMfJ2qdNZZa5Ck/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTQ0Mjcz/Ni0xMTE0NDM3NzAz/LmpwZw.jpeg",
                "cover_image": "https://i.discogs.com/ck9NWi0B-K5RSFktlpYZkJzRqPxPj793WRH1MSXbq3E/rs:fit/g:sm/q:90/h:600/w:600/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTQ0Mjcz/Ni0xMTE0NDM3NzAz/LmpwZw.jpeg",
                "title": "8 Eyed Spy",
                "year": 1981,
                "formats": [{
                  "name": "Vinyl",
                  "qty": "1",
                  "descriptions": ["LP", "Album"]
                }],
                "labels": [{
                  "name": "Fetish Records",
                  "catno": "FR 2003",
                  "entity_type": "1",
                  "entity_type_name": "Label",
                  "id": 4880,
                  "resource_url": "https://api.discogs.com/labels/4880"
                }],
                "artists": [{
                  "name": "8 Eyed Spy",
                  "anv": "",
                  "join": "",
                  "role": "",
                  "tracks": "",
                  "id": 172027,
                  "resource_url": "https://api.discogs.com/artists/172027"
                }],
                "genres": ["Rock"],
                "styles": ["Alternative Rock", "New Wave", "No Wave"]
              },
              "notes": [{
                "field_id": 1,
                "value": "Very Good Plus (VG+)"
              }, {
                "field_id": 2,
                "value": "Very Good Plus (VG+)"
              }, {
                "field_id": 3,
                "value": "nowave"
              }]
            }
        """#

    static let release4 = #"""
            {
              "id": 1427682,
              "instance_id": 236946482,
              "date_added": "2017-06-25T22:07:32-07:00",
              "rating": 0,
              "basic_information": {
                "id": 1427682,
                "master_id": 0,
                "master_url": null,
                "resource_url": "https://api.discogs.com/releases/1427682",
                "thumb": "https://i.discogs.com/6LshffvXygVI3jk7UIzimdit3LhT3t82pi4NHCCivyE/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE0Mjc2/ODItMTI5Njk2MTAw/Ni5qcGVn.jpeg",
                "cover_image": "https://i.discogs.com/IOp7__hT2rzD3OY1ZxwwjhnuWK41XhiHGW2DTAfgMOM/rs:fit/g:sm/q:90/h:600/w:600/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE0Mjc2/ODItMTI5Njk2MTAw/Ni5qcGVn.jpeg",
                "title": "Pocket Calculator (Glomag Mega-Mix) / The Robots",
                "year": 2007,
                "formats": [{
                  "name": "Vinyl",
                  "qty": "1",
                  "descriptions": ["12\"", "33 ⅓ RPM"]
                }],
                "labels": [{
                  "name": "Astralwerks",
                  "catno": "ASW 71190",
                  "entity_type": "1",
                  "entity_type_name": "Label",
                  "id": 188,
                  "resource_url": "https://api.discogs.com/labels/188"
                }, {
                  "name": "Astralwerks",
                  "catno": "094637119013",
                  "entity_type": "1",
                  "entity_type_name": "Label",
                  "id": 188,
                  "resource_url": "https://api.discogs.com/labels/188"
                }],
                "artists": [{
                  "name": "8-bit Operators",
                  "anv": "",
                  "join": "/",
                  "role": "",
                  "tracks": "",
                  "id": 726673,
                  "resource_url": "https://api.discogs.com/artists/726673"
                }, {
                  "name": "8-Bit (2)",
                  "anv": "",
                  "join": "",
                  "role": "",
                  "tracks": "",
                  "id": 168849,
                  "resource_url": "https://api.discogs.com/artists/168849"
                }],
                "genres": ["Electronic"],
                "styles": ["Chiptune", "Techno", "Abstract", "IDM", "Electro", "Synth-pop"]
              },
              "notes": [{
                "field_id": 1,
                "value": "Very Good Plus (VG+)"
              }, {
                "field_id": 2,
                "value": "Very Good Plus (VG+)"
              }, {
                "field_id": 3,
                "value": "electronic"
              }]
            }
        """#

    static let release5 = #"""
        {
            "id": 1700076,
            "instance_id": 163898967,
            "date_added": "2016-03-20T08:01:56-07:00",
            "rating": 0,
            "basic_information": {
                "id": 1700076,
                "master_id": 136187,
                "master_url": "https://api.discogs.com/masters/136187",
                "resource_url": "https://api.discogs.com/releases/1700076",
                "thumb": "https://i.discogs.com/in5FiBVpM58V7iaZYdbMNdYi_rKj2HxVbDPPWhwTfsc/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE3MDAw/NzYtMTIzNzgxODg2/MS5qcGVn.jpeg",
                "cover_image": "https://i.discogs.com/eisTqjZDmbqLYHfzmwGEKT_rF0kVOoYGDTVlc-tb9R0/rs:fit/g:sm/q:90/h:300/w:300/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE3MDAw/NzYtMTIzNzgxODg2/MS5qcGVn.jpeg",
                "title": "The New Possibility: John Fahey's Guitar Soli Christmas Album",
                "year": 1979,
                "formats": [
                    {
                        "name": "Vinyl",
                        "qty": "1",
                        "descriptions": [
                            "LP",
                            "Album",
                            "Reissue"
                        ]
                    }
                ],
                "labels": [
                    {
                        "name": "Takoma",
                        "catno": "TAK 7020",
                        "entity_type": "1",
                        "entity_type_name": "Label",
                        "id": 24549,
                        "resource_url": "https://api.discogs.com/labels/24549"
                    }
                ],
                "artists": [
                    {
                        "name": "John Fahey",
                        "anv": "",
                        "join": "",
                        "role": "",
                        "tracks": "",
                        "id": 65712,
                        "resource_url": "https://api.discogs.com/artists/65712"
                    }
                ],
                "genres": [
                    "Rock",
                    "Folk, World, & Country"
                ],
                "styles": [
                    "Folk Rock",
                    "Acoustic",
                    "Holiday"
                ]
            },
            "notes": [
                {
                    "field_id": 1,
                    "value": "Near Mint (NM or M-)"
                },
                {
                    "field_id": 2,
                    "value": "Very Good Plus (VG+)"
                }
            ]
        }
        """#

    static let release6 = #"""
        {
            "id": 7787184,
            "instance_id": 333642808,
            "date_added": "2018-11-18T10:51:50-08:00",
            "rating": 0,
            "basic_information": {
                "id": 7787184,
                "master_id": 672178,
                "master_url": "https://api.discogs.com/masters/672178",
                "resource_url": "https://api.discogs.com/releases/7787184",
                "thumb": "https://i.discogs.com/JPyPBf3auUa_pfsIqcqo_M7JBxNY3o7fuPbSRUrTcz0/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTc3ODcx/ODQtMTQ0ODc1OTI3/OC0xOTcyLmpwZWc.jpeg",
                "cover_image": "https://i.discogs.com/GHGt0URpLCe4ok90cRhywJmBwEryaWVYqMnCKVBWiJI/rs:fit/g:sm/q:90/h:600/w:600/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTc3ODcx/ODQtMTQ0ODc1OTI3/OC0xOTcyLmpwZWc.jpeg",
                "title": "Empress Rising",
                "year": 2015,
                "formats": [
                    {
                        "name": "Vinyl",
                        "qty": "2",
                        "descriptions": [
                            "LP",
                            "Album",
                            "Limited Edition",
                            "Repress"
                        ]
                    }
                ],
                "labels": [
                    {
                        "name": "RidingEasy Records",
                        "catno": "EZRDR - 021",
                        "entity_type": "1",
                        "entity_type_name": "Label",
                        "id": 698265,
                        "resource_url": "https://api.discogs.com/labels/698265"
                    }
                ],
                "artists": [
                    {
                        "name": "Monolord",
                        "anv": "",
                        "join": "",
                        "role": "",
                        "tracks": "",
                        "id": 3766706,
                        "resource_url": "https://api.discogs.com/artists/3766706"
                    }
                ],
                "genres": [
                    "Rock"
                ],
                "styles": [
                    "Doom Metal"
                ]
            },
            "notes": [
                {
                    "field_id": 3,
                    "value": "doom"
                }
            ]
        }
        """#

    static let release7 = #"""
        {
            "id": 14462207,
            "instance_id": 842890279,
            "date_added": "2021-10-28T21:46:33-07:00",
            "rating": 0,
            "basic_information": {
                "id": 14462207,
                "master_id": 44401,
                "master_url": "https://api.discogs.com/masters/44401",
                "resource_url": "https://api.discogs.com/releases/14462207",
                "thumb": "https://i.discogs.com/qQ-cP7-E2VEhMHVt6RP5hOgwlLBj9pH3gUMXQuVQNWU/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE0NDYy/MjA3LTE1NzUxOTAy/NTgtMjI0Mi5qcGVn.jpeg",
                "cover_image": "https://i.discogs.com/XNKzuKtA-X3emrWfmX0tOmL4JdjdyOuRJ5xWfyrtEE4/rs:fit/g:sm/q:90/h:600/w:600/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTE0NDYy/MjA3LTE1NzUxOTAy/NTgtMjI0Mi5qcGVn.jpeg",
                "title": "The Raven",
                "year": 2019,
                "formats": [
                    {
                        "name": "Vinyl",
                        "qty": "3",
                        "text": "180 g",
                        "descriptions": [
                            "LP",
                            "Album",
                            "Record Store Day",
                            "Limited Edition",
                            "Reissue"
                        ]
                    }
                ],
                "labels": [
                    {
                        "name": "Sire",
                        "catno": "R1 48372",
                        "entity_type": "1",
                        "entity_type_name": "Label",
                        "id": 27031,
                        "resource_url": "https://api.discogs.com/labels/27031"
                    },
                    {
                        "name": "Sire",
                        "catno": "603497850150",
                        "entity_type": "1",
                        "entity_type_name": "Label",
                        "id": 27031,
                        "resource_url": "https://api.discogs.com/labels/27031"
                    },
                    {
                        "name": "Reprise Records",
                        "catno": "R1 48372",
                        "entity_type": "1",
                        "entity_type_name": "Label",
                        "id": 157,
                        "resource_url": "https://api.discogs.com/labels/157"
                    },
                    {
                        "name": "Reprise Records",
                        "catno": "603497850150",
                        "entity_type": "1",
                        "entity_type_name": "Label",
                        "id": 157,
                        "resource_url": "https://api.discogs.com/labels/157"
                    }
                ],
                "artists": [
                    {
                        "name": "Lou Reed",
                        "anv": "",
                        "join": "",
                        "role": "",
                        "tracks": "",
                        "id": 11879,
                        "resource_url": "https://api.discogs.com/artists/11879"
                    }
                ],
                "genres": [
                    "Electronic",
                    "Rock",
                    "Non-Music"
                ],
                "styles": [
                    "Alternative Rock",
                    "Avantgarde",
                    "Experimental",
                    "Pop Rock",
                    "Spoken Word",
                    "Dialogue"
                ]
            },
            "notes": [
                {
                    "field_id": 1,
                    "value": "Near Mint (NM or M-)"
                },
                {
                    "field_id": 2,
                    "value": "Very Good Plus (VG+)"
                }
            ]
        }
        """#

    static let numItems = 7

    static let sevenItemsPageResponseData: Data = """
        {
            "releases": [\(release1), \(release2), \(release3), \(release4), \(release5), \(release6), \(release7)]
        }
        """.data(using: .utf8)!

    static let oneItemPage1ResponseData: Data = """
        {
            "releases": [\(release1)]
        }
        """.data(using: .utf8)!

    static let oneItemPage2ResponseData: Data = """
        {
            "releases": [\(release2)]
        }
        """.data(using: .utf8)!

    static let oneItemPage3ResponseData: Data = """
        {
            "releases": [\(release3)]
        }
        """.data(using: .utf8)!

    static let oneItemPage4ResponseData: Data = """
        {
            "releases": [\(release4)]
        }
        """.data(using: .utf8)!

    static let oneItemPage5ResponseData: Data = """
        {
            "releases": [\(release5)]
        }
        """.data(using: .utf8)!

    static let oneItemPage6ResponseData: Data = """
        {
            "releases": [\(release6)]
        }
        """.data(using: .utf8)!

    static let oneItemPage7ResponseData: Data = """
        {
            "releases": [\(release7)]
        }
        """.data(using: .utf8)!

    static let twoItemMaxPage1ResponseData: Data = """
        {
            "releases": [\(release1), \(release2)]
        }
        """.data(using: .utf8)!

    static let twoItemMaxPage2ResponseData: Data = """
        {
            "releases": [\(release3), \(release4)]
        }
        """.data(using: .utf8)!

    static let twoItemMaxPage3ResponseData: Data = """
        {
            "releases": [\(release5), \(release6)]
        }
        """.data(using: .utf8)!

    static let twoItemMaxPage4ResponseData: Data = """
        {
            "releases": [\(release7)]
        }
        """.data(using: .utf8)!

    static let fourItemMaxPage1ResponseData: Data = """
        {
            "releases": [\(release1), \(release2), \(release3), \(release4)]
        }
        """.data(using: .utf8)!

    static let fourItemMaxPage2ResponseData: Data = """
        {
            "releases": [\(release5), \(release6), \(release7)]
        }
        """.data(using: .utf8)!


    // MARK: - Helper Methods

    private func createSUT(mockSession: MockURLSession) async -> APIService {
        let apiService = APIService(
            consumerKey: testConsumerKey,
            consumerSecret: testConsumerSecret,
            baseURL: testBaseURL,
            urlSession: mockSession
        )
        await apiService.setFakeAccessToken()
        return apiService
    }

    @Test func testGetCollectionSequentially() async throws {
        let username = "fakeuser"
        let perPage = 2

        let rootEndpoint = "\(testBaseURL)/users/\(username)/collection/folders/0/releases?sort=artist&sort_order=asc&per_page=\(perPage)"

        let dummyResponse = HTTPURLResponse(
            url: URL(string: testBaseURL)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!

        let urlSession = MockURLSession()
        let sut = await createSUT(mockSession: urlSession)

        let req1 = try await sut.createRequest("GET", "\(rootEndpoint)&page=1")
        let req2 = try await sut.createRequest("GET", "\(rootEndpoint)&page=2")
        let req3 = try await sut.createRequest("GET", "\(rootEndpoint)&page=3")
        let req4 = try await sut.createRequest("GET", "\(rootEndpoint)&page=4")

        let traffic = [
            req1.hashValue: (CollectionAPITests.twoItemMaxPage1ResponseData,
                             dummyResponse),
            req2.hashValue: (CollectionAPITests.twoItemMaxPage2ResponseData,
                             dummyResponse),
            req3.hashValue: (CollectionAPITests.twoItemMaxPage3ResponseData,
                             dummyResponse),
            req4.hashValue: (CollectionAPITests.twoItemMaxPage4ResponseData,
                             dummyResponse),
        ]
        urlSession.traffic = traffic

        let collection = await sut.getCollection(forUser: username,
                                                 withMaxConcurrency: 1,
                                                 numberOfItems: CollectionAPITests.numItems,
                                                 perPage: perPage)

        // verify all releases are parsed correctly and kept in order
        #expect(collection.failedPages.count == 0)
        let releases = collection.releases
        #expect(releases.count == CollectionAPITests.numItems)
        #expect(releases[0].id == "7676896")
        #expect(releases[1].id == "7734706")
        #expect(releases[2].id == "442736")
        #expect(releases[3].id == "1427682")
        #expect(releases[4].id == "1700076")
        #expect(releases[5].id == "7787184")
        #expect(releases[6].id == "14462207")
    }

    @Test func testGetCollectionConcurrently() async throws {
        // set up
        let username = "fakeuser"
        let perPage = 1

        let rootEndpoint = "\(testBaseURL)/users/\(username)/collection/folders/0/releases?sort=artist&sort_order=asc&per_page=\(perPage)"

        let dummyResponse = HTTPURLResponse(
            url: URL(string: testBaseURL)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!

        let urlSession = MockURLSession()
        let sut = await createSUT(mockSession: urlSession)

        let req1 = try await sut.createRequest("GET", "\(rootEndpoint)&page=1")
        let req2 = try await sut.createRequest("GET", "\(rootEndpoint)&page=2")
        let req3 = try await sut.createRequest("GET", "\(rootEndpoint)&page=3")
        let req4 = try await sut.createRequest("GET", "\(rootEndpoint)&page=4")
        let req5 = try await sut.createRequest("GET", "\(rootEndpoint)&page=5")
        let req6 = try await sut.createRequest("GET", "\(rootEndpoint)&page=6")
        let req7 = try await sut.createRequest("GET", "\(rootEndpoint)&page=7")

        let traffic = [
            req1.hashValue: (CollectionAPITests.oneItemPage1ResponseData,
                             dummyResponse),
            req2.hashValue: (CollectionAPITests.oneItemPage2ResponseData,
                             dummyResponse),
            req3.hashValue: (CollectionAPITests.oneItemPage3ResponseData,
                             dummyResponse),
            req4.hashValue: (CollectionAPITests.oneItemPage4ResponseData,
                             dummyResponse),
            req5.hashValue: (CollectionAPITests.oneItemPage5ResponseData,
                             dummyResponse),
            req6.hashValue: (CollectionAPITests.oneItemPage6ResponseData,
                             dummyResponse),
            req7.hashValue: (CollectionAPITests.oneItemPage7ResponseData,
                             dummyResponse),
        ]
        urlSession.traffic = traffic

        // test
        let collection = await sut.getCollection(
            forUser: username,
            withMaxConcurrency: 3,
            numberOfItems: CollectionAPITests.numItems,
            perPage: perPage)

        // verify
        #expect(collection.failedPages.count == 0)
        let releases = collection.releases
        #expect(releases.count == CollectionAPITests.numItems)
        #expect(releases[0].id == "7676896")
        #expect(releases[1].id == "7734706")
        #expect(releases[2].id == "442736")
        #expect(releases[3].id == "1427682")
        #expect(releases[4].id == "1700076")
        #expect(releases[5].id == "7787184")
        #expect(releases[6].id == "14462207")
    }

    @Test func testGetCollectionConcurrentlyDifferentPageSizes() async throws {
        // set up
        let username = "fakeuser"
        let perPage = 2

        let rootEndpoint = "\(testBaseURL)/users/\(username)/collection/folders/0/releases?sort=artist&sort_order=asc&per_page=\(perPage)"

        let dummyResponse = HTTPURLResponse(
            url: URL(string: testBaseURL)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!

        let urlSession = MockURLSession()
        let sut = await createSUT(mockSession: urlSession)

        let req1 = try await sut.createRequest("GET", "\(rootEndpoint)&page=1")
        let req2 = try await sut.createRequest("GET", "\(rootEndpoint)&page=2")
        let req3 = try await sut.createRequest("GET", "\(rootEndpoint)&page=3")
        let req4 = try await sut.createRequest("GET", "\(rootEndpoint)&page=4")

        let traffic = [
            req1.hashValue: (CollectionAPITests.twoItemMaxPage1ResponseData,
                             dummyResponse),
            req2.hashValue: (CollectionAPITests.twoItemMaxPage2ResponseData,
                             dummyResponse),
            req3.hashValue: (CollectionAPITests.twoItemMaxPage3ResponseData,
                             dummyResponse),
            req4.hashValue: (CollectionAPITests.twoItemMaxPage4ResponseData,
                             dummyResponse),
        ]
        urlSession.traffic = traffic

        // test
        let collection = await sut.getCollection(
            forUser: username,
            withMaxConcurrency: 2,
            numberOfItems: CollectionAPITests.numItems,
            perPage: perPage)

        // verify
        #expect(collection.failedPages.count == 0)
        let releases = collection.releases
        #expect(releases.count == CollectionAPITests.numItems)
        #expect(releases[0].id == "7676896")
        #expect(releases[1].id == "7734706")
        #expect(releases[2].id == "442736")
        #expect(releases[3].id == "1427682")
        #expect(releases[4].id == "1700076")
        #expect(releases[5].id == "7787184")
        #expect(releases[6].id == "14462207")
    }

    @Test func testGetCollectionConcurrentlyWithSomeError() async throws {
        // set up
        let username = "fakeuser"
        let perPage = 2

        let rootEndpoint = "\(testBaseURL)/users/\(username)/collection/folders/0/releases?sort=artist&sort_order=asc&per_page=\(perPage)"

        let dummySuccessResponse = HTTPURLResponse(
            url: URL(string: testBaseURL)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
        let dummyFailResponse = HTTPURLResponse(
            url: URL(string: testBaseURL)!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil)!


        let urlSession = MockURLSession()
        let sut = await createSUT(mockSession: urlSession)

        let req1 = try await sut.createRequest("GET", "\(rootEndpoint)&page=1")
        let req2 = try await sut.createRequest("GET", "\(rootEndpoint)&page=2")
        let req3 = try await sut.createRequest("GET", "\(rootEndpoint)&page=3")
        let req4 = try await sut.createRequest("GET", "\(rootEndpoint)&page=4")

        let traffic = [
            req1.hashValue: (CollectionAPITests.twoItemMaxPage1ResponseData,
                             dummySuccessResponse),
            req2.hashValue: (CollectionAPITests.twoItemMaxPage2ResponseData,
                             dummySuccessResponse),
            req3.hashValue: ("esorciccio".data(using: .utf8)!,
                             dummyFailResponse),
            req4.hashValue: (CollectionAPITests.twoItemMaxPage4ResponseData,
                             dummySuccessResponse),
        ]
        urlSession.traffic = traffic

        // test
        let collection = await sut.getCollection(
            forUser: username,
            withMaxConcurrency: 2,
            numberOfItems: CollectionAPITests.numItems,
            perPage: perPage)

        // verify
        #expect(collection.failedPages.count == 1)
        #expect(collection.failedPages.contains(3))
        let releases = collection.releases
        #expect(releases.count == CollectionAPITests.numItems - perPage)
        #expect(releases[0].id == "7676896")    // page 1
        #expect(releases[1].id == "7734706")    //  ...
        #expect(releases[2].id == "442736")     // page 2
        #expect(releases[3].id == "1427682")    // ...
        #expect(releases[4].id == "14462207")   // page 4
    }

}
