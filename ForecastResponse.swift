//
//  ForecastResponse.swift
//  Glasscast
//

import Foundation

/// OpenWeatherMap `/forecast` response (5 day / 3 hour forecast).
struct ForecastResponse: Codable {
    let list: [ForecastItem]

    struct ForecastItem: Codable {
        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
        let dtText: String

        enum CodingKeys: String, CodingKey {
            case dt
            case main
            case weather
            case dtText = "dt_txt"
        }
    }

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

