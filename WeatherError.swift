//
//  WeatherError.swift
//  Glasscast
//

import Foundation

enum WeatherError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingError
    case transportError(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing OpenWeatherMap API key."
        case .invalidURL:
            return "Invalid weather API URL."
        case .requestFailed(let statusCode):
            return "Weather API request failed (HTTP \(statusCode))."
        case .decodingError:
            return "Failed to decode weather data."
        case .transportError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        }
    }
}

