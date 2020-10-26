//
//  Network.swift
//  WBikes
//
//  Created by Diego on 14/10/2020.
//

import Foundation

struct NetworkRes: Codable {
    let id: String
    let location: Location
    let name: String
    let source: String?
    let stations: [StationRes]?
}

struct Location: Codable {
    let city, country: String
    let latitude, longitude: Double
}
