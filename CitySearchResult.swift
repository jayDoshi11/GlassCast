//
//  CitySearchResult.swift
//  Glasscast
//
//  Model for city search results from OpenWeatherMap Geocoding API
//

import Foundation

struct CitySearchResult: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let country: String?
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case lat
        case lon
        case country
        case state
    }
    
    init(name: String, lat: Double, lon: Double, country: String? = nil, state: String? = nil) {
        self.id = "\(lat),\(lon)"
        self.name = name
        self.lat = lat
        self.lon = lon
        self.country = country
        self.state = state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        id = "\(lat),\(lon)"
    }
    
    var displayName: String {
        var components = [name]
        if let state = state {
            components.append(state)
        }
        if let country = country {
            components.append(country)
        }
        return components.joined(separator: ", ")
    }
}
