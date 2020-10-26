//
//  Cliente.swift
//  WBikes
//
//  Created by Diego on 14/10/2020.
//

import Foundation
import CoreData

class Cliente {
    
    enum Endpoints {
        static let base = "https://api.citybik.es/v2/networks"
        
        case stations(String)
        case networks
        
        var stringValue: String {
            switch self {
            case .networks: return Endpoints.base
            case .stations(let id): return "\(Endpoints.base)/\(id)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getStations(city: City, dataController: DataController, completion: @escaping ([Station], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.stations(city.id!).url, responseType: StationResponse.self) { response, error in
            if let response = response?.network.stations {
                let stations = saveStations(stationResponse: response, city: city, dataController: dataController)
                completion(stations, nil)
            }else{
                completion(getStations(dataController: dataController), error)
            }
        }
    }
    
    class fileprivate func saveStations(stationResponse: [StationRes], city: City,  dataController: DataController) -> [Station]{
        var stations = [Station]()
        let result = getStations(dataController: dataController)
        stationResponse.forEach{ stationResponse in
            if let station = result.first(where: { $0.id == stationResponse.id}) {
                station.emptySlots = Int64(stationResponse.emptySlots)
                station.freeBikes = Int64(stationResponse.freeBikes)
                stations.append(station)
            }else{
                let station = Station(context: dataController.viewContext)
                station.id = stationResponse.id
                station.address = stationResponse.extra.address
                station.name = stationResponse.name
                station.emptySlots = Int64(stationResponse.emptySlots)
                station.freeBikes = Int64(stationResponse.freeBikes)
                station.latitude = stationResponse.latitude!
                station.longitude = stationResponse.longitude!
                station.city = city
                stations.append(station)
            }
        }
        dataController.save()
        return stations
    }
    
    class func getStations(dataController: DataController) -> [Station] {
        let fetchRequest:NSFetchRequest<Station> = Station.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let result = try? dataController.viewContext.fetch(fetchRequest)
        return result ?? [Station]()
    }
    
    class func getCitys(completion: @escaping ([CitysByCountry], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.networks.url, responseType: NetworksResponse.self) { response, error in
            if let response = response{
                let orderCitys = self.orderCitys(networks: response.networks)
                completion(orderCitys, nil)
            }else{
                completion([CitysByCountry](), error)
            }
        }
    }
    
    class func orderCitys(networks: [NetworkRes]) -> [CitysByCountry]{
        var cityByCountry = [CitysByCountry]()
        let groupByCountry = Dictionary(grouping: networks) { (network) -> String in
            return countryName(countryCode: network.location.country)
        }
        let groupByCountrySorted = groupByCountry.sorted { $0.key < $1.key }
        
        groupByCountrySorted.forEach { (country, networks) in
            var citys = [CityResponse]()
            networks.forEach { network in
                citys.append(CityResponse(id: network.id, name: network.location.city, latitude: network.location.latitude, longitude: network.location.longitude))
            }
            let sortedCitys = citys.sorted { $0.name < $1.name }
            let country = CitysByCountry(country: country, citys: sortedCitys)
            cityByCountry.append(country)
        }
        return cityByCountry
    }
    
    class func countryName(countryCode: String) -> String  {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            return name
        } else {
            return countryCode
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}
