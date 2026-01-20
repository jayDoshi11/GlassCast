//
//  UnitManager.swift
//  Glasscast
//
//  Manages temperature unit preferences
//

import Foundation
import SwiftUI

@MainActor
final class UnitManager: ObservableObject {
    static let shared = UnitManager()
    
    @Published var isMetric: Bool {
        didSet {
            UserDefaults.standard.set(isMetric, forKey: "temperatureUnitIsMetric")
        }
    }
    
    var temperatureUnit: UnitTemperature {
        isMetric ? .celsius : .fahrenheit
    }
    
    private init() {
        // Default to metric (Celsius) if not set
        self.isMetric = UserDefaults.standard.object(forKey: "temperatureUnitIsMetric") as? Bool ?? true
    }
    
    /// Convert temperature from Kelvin to user's preferred unit
    func convertFromKelvin(_ kelvin: Double) -> Double {
        let measurement = Measurement(value: kelvin, unit: UnitTemperature.kelvin)
        return measurement.converted(to: temperatureUnit).value
    }
    
    /// Convert temperature from Celsius to user's preferred unit
    func convertFromCelsius(_ celsius: Double) -> Double {
        let measurement = Measurement(value: celsius, unit: UnitTemperature.celsius)
        return measurement.converted(to: temperatureUnit).value
    }
    
    /// Format temperature with unit symbol
    func formatTemperature(_ temperature: Double, fromKelvin: Bool = false) -> String {
        let convertedTemp = fromKelvin ? convertFromKelvin(temperature) : convertFromCelsius(temperature)
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitOptions = .providedUnit
        
        let measurement = Measurement(value: convertedTemp, unit: temperatureUnit)
        return formatter.string(from: measurement)
    }
    
    /// Get unit symbol (e.g., "°C" or "°F")
    var unitSymbol: String {
        isMetric ? "°C" : "°F"
    }
}
