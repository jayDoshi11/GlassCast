//
//  WeatherService.swift
//  Glasscast
//
//  Weather API service using OpenWeatherMap
//

import Foundation

/// Service for fetching weather data from OpenWeatherMap API
actor WeatherService {
    static let shared = WeatherService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let apiKey = Secrets.weatherAPIKey
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
    
    private init() {}
    
    /// Fetch combined current weather + 5-day forecast for a city.
    func fetchWeather(for city: String) async throws -> (WeatherResponse, [ForecastResponse.ForecastItem], WeatherModel) {
        guard !apiKey.isEmpty else { throw WeatherError.missingAPIKey }
        
        async let current = fetchCurrentWeather(city: city)
        async let forecast = fetchForecast(city: city)
        
        let (currentWeather, forecastResponse) = try await (current, forecast)
        let filteredForecast = Self.filterDaily(forecastResponse.list)
        let model = Self.mapToWeatherModel(current: currentWeather, daily: filteredForecast)
        return (currentWeather, filteredForecast, model)
    }
    
    /// Fetch combined current weather + 5-day forecast by coordinates.
    func fetchWeather(lat: Double, lon: Double) async throws -> (WeatherResponse, [ForecastResponse.ForecastItem], WeatherModel) {
        guard !apiKey.isEmpty else { throw WeatherError.missingAPIKey }
        
        async let current = fetchCurrentWeather(lat: lat, lon: lon)
        async let forecast = fetchForecast(lat: lat, lon: lon)
        
        let (currentWeather, forecastResponse) = try await (current, forecast)
        let filteredForecast = Self.filterDaily(forecastResponse.list)
        let model = Self.mapToWeatherModel(current: currentWeather, daily: filteredForecast)
        return (currentWeather, filteredForecast, model)
    }
    
    private func fetchCurrentWeather(city: String) async throws -> WeatherResponse {
        guard let url = makeURL(path: "/weather", city: city) else { throw WeatherError.invalidURL }
        let (data, response) = try await makeRequest(url: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard 200..<300 ~= status else { throw WeatherError.requestFailed(statusCode: status) }
        do {
            return try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
    
    private func fetchForecast(city: String) async throws -> ForecastResponse {
        guard let url = makeURL(path: "/forecast", city: city) else { throw WeatherError.invalidURL }
        let (data, response) = try await makeRequest(url: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard 200..<300 ~= status else { throw WeatherError.requestFailed(statusCode: status) }
        do {
            return try decoder.decode(ForecastResponse.self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
    
    private func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard let url = makeURL(path: "/weather", lat: lat, lon: lon) else { throw WeatherError.invalidURL }
        let (data, response) = try await makeRequest(url: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard 200..<300 ~= status else { throw WeatherError.requestFailed(statusCode: status) }
        do {
            return try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
    
    private func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        guard let url = makeURL(path: "/forecast", lat: lat, lon: lon) else { throw WeatherError.invalidURL }
        let (data, response) = try await makeRequest(url: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard 200..<300 ~= status else { throw WeatherError.requestFailed(statusCode: status) }
        do {
            return try decoder.decode(ForecastResponse.self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
    
    private func makeURL(path: String, city: String) -> URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        return components?.url
    }
    
    private func makeURL(path: String, lat: Double, lon: Double) -> URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        return components?.url
    }
    
    private func makeRequest(url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(from: url)
        } catch {
            throw WeatherError.transportError(underlying: error)
        }
    }
    
    // MARK: - Mapping helpers
    
    private static func filterDaily(_ items: [ForecastResponse.ForecastItem]) -> [ForecastResponse.ForecastItem] {
        let calendar = Calendar.current
        var grouped: [DateComponents: [ForecastResponse.ForecastItem]] = [:]
        
        for item in items {
            let date = Date(timeIntervalSince1970: item.dt)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            grouped[components, default: []].append(item)
        }
        
        let noon = DateComponents(hour: 12, minute: 0)
        
        let selected = grouped
            .compactMap { comps, values -> ForecastResponse.ForecastItem? in
                guard let dayDate = calendar.date(from: comps) else { return nil }
                let target = calendar.date(bySettingHour: noon.hour ?? 12, minute: noon.minute ?? 0, second: 0, of: dayDate) ?? dayDate
                
                return values.min(by: { lhs, rhs in
                    let lhsDate = Date(timeIntervalSince1970: lhs.dt)
                    let rhsDate = Date(timeIntervalSince1970: rhs.dt)
                    return abs(lhsDate.timeIntervalSince(target)) < abs(rhsDate.timeIntervalSince(target))
                })
            }
            .sorted { $0.dt < $1.dt }
        
        return Array(selected.prefix(5))
    }
    
    private static func mapToWeatherModel(current: WeatherResponse, daily: [ForecastResponse.ForecastItem]) -> WeatherModel {
        let dailyModels: [WeatherModel.DailyForecast] = daily.map { item in
            let date = Date(timeIntervalSince1970: item.dt)
            let min = item.main.tempMin ?? item.main.temp
            let max = item.main.tempMax ?? item.main.temp
            let description = item.weather.first?.description ?? ""
            let icon = item.weather.first?.icon
            return WeatherModel.DailyForecast(date: date, minTemp: min, maxTemp: max, description: description, icon: icon)
        }
        
        let description = current.weather.first?.description ?? ""
        let icon = current.weather.first?.icon
        
        return WeatherModel(
            cityName: current.name,
            currentTemp: current.main.temp,
            currentDescription: description,
            currentIcon: icon,
            daily: dailyModels
        )
    }
    
    /// Search for cities by name using OpenWeatherMap Geocoding API
    func searchCity(query: String) async throws -> [CitySearchResult] {
        guard !apiKey.isEmpty else { throw WeatherError.missingAPIKey }
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        let geocodeURL = "https://api.openweathermap.org/geo/1.0/direct"
        var components = URLComponents(string: geocodeURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components?.url else { throw WeatherError.invalidURL }
        
        let (data, response) = try await makeRequest(url: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard 200..<300 ~= status else { throw WeatherError.requestFailed(statusCode: status) }
        
        do {
            return try decoder.decode([CitySearchResult].self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
}

