//
//  WeatherResponse.swift
//  Glasscast
//

import Foundation

/// OpenWeatherMap `/weather` response (subset used by the app).
struct WeatherResponse: Codable {
    let name: String
    let dt: TimeInterval
    let main: Main
    let weather: [Weather]

    struct Main: Codable {
        let temp: Double
        let tempMin: Double?
        let tempMax: Double?

        enum CodingKeys: String, CodingKey {
            case temp
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }
    }

    struct Weather: Codable {
        let description: String
        let icon: String?
    }
}

