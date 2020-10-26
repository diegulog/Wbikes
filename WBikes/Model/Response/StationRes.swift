//
//  Stations.swift
//  WBikes
//
//  Created by Diego on 14/10/2020.
//

import Foundation

struct StationRes: Codable {
    let emptySlots: Int
    let extra: Extra
    let freeBikes: Int
    let id: String?
    let latitude, longitude: Double?
    let name, timestamp: String?

    enum CodingKeys: String, CodingKey {
        case emptySlots = "empty_slots"
        case extra
        case freeBikes = "free_bikes"
        case id, latitude, longitude, name, timestamp
    }
}

struct Extra: Codable {
    let address: String?
}
