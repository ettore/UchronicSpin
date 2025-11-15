//
//  APIModels.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/26/25.
//


struct APIFolder: Codable, Sendable {
    let id: Int
    let count: Int
    let name: String
    let resourceUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case count
        case name
        case resourceUrl = "resource_url"
    }
}

