//
//  CitysByCountry.swift
//  WBikes
//
//  Created by Diego on 15/10/2020.
//

import Foundation

struct CitysByCountry {
    let country: String
    let citys: [CityResponse]
}

struct CityResponse {
    let id: String
    let name: String
    let latitude, longitude : Double
}
