//
//  NetworksResponse.swift
//  WBikes
//
//  Created by Diego on 14/10/2020.
//

import Foundation
struct NetworksResponse: Codable {
    let networks: [NetworkRes]
}

struct StationResponse: Codable {
    let network: NetworkRes
}






