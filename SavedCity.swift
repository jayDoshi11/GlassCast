//
//  SavedCity.swift
//  Glasscast
//
//  Model for saved favorite cities from Supabase
//

import Foundation

struct SavedCity: Codable, Identifiable, Hashable {
    var id: String {
        // Generate unique ID from coordinates and city name
        "\(userId)_\(lat)_\(lon)_\(cityName)"
    }
    let userId: String
    let cityName: String
    let lat: Double
    let lon: Double
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case cityName = "city_name"
        case lat
        case lon
        case createdAt = "created_at"
    }
}
