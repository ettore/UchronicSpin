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

    let fourItemsPageResponse: Data = #"""
        {
            "releases": [{
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
            }, {
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
            }, {
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
            }, {
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
          ]
        }
        """#.data(using: .utf8)!


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
        let sut = await createSUT(mockSession: MockURLSession(data: fourItemsPageResponse))
        let collection = await sut.getCollection(forUser: "testuser",
                                                 withMaxConcurrency: 1,
                                                 numberOfItems: 4,
                                                 perPage: 4)

        // verify all releases are parsed correctly and kept in order
        #expect(collection.failedPages.count == 0)
        let releases = collection.releases
        #expect(releases.count == 4)
        #expect(releases[0].id == "7676896")
        #expect(releases[1].id == "7734706")
        #expect(releases[2].id == "442736")
        #expect(releases[3].id == "1427682")
    }
}
