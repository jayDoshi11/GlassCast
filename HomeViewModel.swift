//
//  HomeViewModel.swift
//  Glasscast
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var currentWeather: WeatherResponse?
    @Published var forecast: [ForecastResponse.ForecastItem]?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service: WeatherService
    private let unitManager: UnitManager
    private var lastCity: String = "San Francisco"
    private var lastSavedCity: SavedCity?
    
    init(service: WeatherService = .shared, unitManager: UnitManager = .shared) {
        self.service = service
        self.unitManager = unitManager
    }
    
    /// Get formatted current temperature
    func formattedCurrentTemp() -> String {
        guard let temp = currentWeather?.main.temp else { return "—" }
        return unitManager.formatTemperature(temp, fromKelvin: false) // API returns Celsius
    }
    
    /// Get formatted temperature for forecast item
    func formattedTemp(_ temp: Double) -> String {
        return unitManager.formatTemperature(temp, fromKelvin: false)
    }
    
    /// Get temperature unit symbol
    var unitSymbol: String {
        unitManager.unitSymbol
    }
    
    func fetchWeather(for city: String) {
        let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        lastCity = trimmed
        lastSavedCity = nil
        
        Task {
            do {
                let (current, daily, _) = try await service.fetchWeather(for: trimmed)
                self.currentWeather = current
                self.forecast = daily
            } catch {
                self.errorMessage = (error as? WeatherError)?.localizedDescription ?? error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func fetchWeather(for savedCity: SavedCity) {
        isLoading = true
        errorMessage = nil
        lastSavedCity = savedCity
        lastCity = savedCity.cityName
        
        Task {
            do {
                let (current, daily, _) = try await service.fetchWeather(lat: savedCity.lat, lon: savedCity.lon)
                self.currentWeather = current
                self.forecast = daily
            } catch {
                self.errorMessage = (error as? WeatherError)?.localizedDescription ?? error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func refresh() {
        if let savedCity = lastSavedCity {
            fetchWeather(for: savedCity)
        } else {
            fetchWeather(for: lastCity)
        }
    }
    
    func mapIcon(code: String?) -> String {
        guard let code = code else { return "questionmark.circle" }
        let mapping: [String: String] = [
            "01d": "sun.max.fill",
            "01n": "moon.stars.fill",
            "02d": "cloud.sun.fill",
            "02n": "cloud.moon.fill",
            "03d": "cloud.fill",
            "03n": "cloud.fill",
            "04d": "smoke.fill",
            "04n": "smoke.fill",
            "09d": "cloud.drizzle.fill",
            "09n": "cloud.drizzle.fill",
            "10d": "cloud.rain.fill",
            "10n": "cloud.rain.fill",
            "11d": "cloud.bolt.rain.fill",
            "11n": "cloud.bolt.rain.fill",
            "13d": "snowflake",
            "13n": "snowflake",
            "50d": "cloud.fog.fill",
            "50n": "cloud.fog.fill"
        ]
        return mapping[code, default: "questionmark.circle"]
    }
}

