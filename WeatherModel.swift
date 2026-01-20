//
//  WeatherModel.swift
//  Glasscast
//

import Foundation

/// App-facing combined model (current weather + daily forecast).
struct WeatherModel: Sendable {
    let cityName: String
    let currentTemp: Double
    let currentDescription: String
    let currentIcon: String?
    let daily: [DailyForecast]

    struct DailyForecast: Sendable, Identifiable {
        let id = UUID()
        let date: Date
        let minTemp: Double
        let maxTemp: Double
        let description: String
        let icon: String?
    }
}

