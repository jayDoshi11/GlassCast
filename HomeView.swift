//
//  HomeView.swift
//  Glasscast
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var unitManager = UnitManager.shared
    @State private var selectedCity: SavedCity?
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @State private var didTapHero = false
    
    private let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.9), value: backgroundKey)
                
                ScrollView {
                    VStack(spacing: 20) {
                        heroWeatherCard
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.85)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.98)
                            }
                        
                        dailyForecastSection
                    }
                    .padding()
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Glasscast")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await MainActor.run {
                    viewModel.refresh()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("Error", isPresented: Binding(get: {
                viewModel.errorMessage != nil
            }, set: { _ in
                viewModel.errorMessage = nil
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Something went wrong.")
            }
        }
        .onAppear {
            if let city = selectedCity {
                viewModel.fetchWeather(for: city)
            } else {
                viewModel.fetchWeather(for: "San Francisco")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SelectedCity"))) { notification in
            if let city = notification.object as? SavedCity {
                selectedCity = city
                viewModel.fetchWeather(for: city)
            }
        }
    }
    
    private var backgroundKey: String {
        // Drives background animation changes based on current weather icon (or fallback).
        viewModel.currentWeather?.weather.first?.icon ?? "default"
    }
    
    private var backgroundGradient: LinearGradient {
        let icon = viewModel.currentWeather?.weather.first?.icon ?? ""
        let isDark = (colorScheme == .dark)
        
        // Keep this strictly system colors (no custom hex).
        let colors: [Color] = {
            // Broad buckets based on OpenWeather icon codes.
            if icon.hasPrefix("01") { // clear
                return isDark ? [.indigo, .black, .blue] : [.yellow, .orange, .pink]
            } else if icon.hasPrefix("02") || icon.hasPrefix("03") || icon.hasPrefix("04") { // clouds
                return isDark ? [.gray, .indigo, .black] : [.mint, .cyan, .blue]
            } else if icon.hasPrefix("09") || icon.hasPrefix("10") { // rain
                return isDark ? [.blue, .indigo, .black] : [.cyan, .blue, .indigo]
            } else if icon.hasPrefix("11") { // thunder
                return isDark ? [.purple, .indigo, .black] : [.purple, .indigo, .blue]
            } else if icon.hasPrefix("13") { // snow
                return isDark ? [.teal, .indigo, .black] : [.white, .cyan, .blue]
            } else if icon.hasPrefix("50") { // mist
                return isDark ? [.gray, .black, .indigo] : [.gray.opacity(0.6), .white, .mint]
            }
            return isDark ? [.indigo, .black, .blue] : [.blue, .purple, .pink]
        }()
        
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var heroWeatherCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(reduceTransparency ? Color.black.opacity(0.25) : .regularMaterial)
                .overlay {
                    // Joyful tint that subtly follows the background palette.
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(backgroundGradient.opacity(colorScheme == .dark ? 0.18 : 0.22))
                }
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .symbolRenderingMode(.hierarchical)
                        .symbolEffect(.pulse, value: viewModel.currentWeather?.name ?? "")
                    
                    Text(viewModel.currentWeather?.name ?? "—")
                        .font(.title2.weight(.semibold))
                    
                    Spacer()
                    
                    // Unit chip
                    Text(unitManager.isMetric ? "°C" : "°F")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(reduceTransparency ? Color.white.opacity(0.15) : .thinMaterial, in: Capsule())
                }
                .foregroundStyle(.white)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 16) {
                    if let iconCode = viewModel.currentWeather?.weather.first?.icon {
                        Image(systemName: viewModel.mapIcon(code: iconCode))
                            .font(.system(size: 84))
                            .symbolRenderingMode(.multicolor)
                            .symbolEffect(reduceMotion ? .none : .variableColor.iterative, value: iconCode)
                            .scaleEffect(didTapHero ? 1.05 : 1.0)
                            .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.62), value: didTapHero)
                    } else {
                        Image(systemName: "cloud.sun.fill")
                            .font(.system(size: 84))
                            .symbolRenderingMode(.multicolor)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.formattedCurrentTemp())
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        
                        if let description = viewModel.currentWeather?.weather.first?.description {
                            Text(description.capitalized)
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white.opacity(0.92))
                        } else {
                            Text("—")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(height: 350)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.12), radius: 18, y: 10)
        .sensoryFeedback(.impact(weight: .medium), trigger: didTapHero)
        .onTapGesture {
            guard !reduceMotion else { return }
            didTapHero.toggle()
        }
    }
    
    private var dailyForecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("5‑Day Forecast")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                if viewModel.forecast != nil {
                    Image(systemName: "sparkles")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white.opacity(0.8))
                        .symbolEffect(reduceMotion ? .none : .pulse, value: viewModel.forecast?.count ?? 0)
                }
            }
            
            if let forecast = viewModel.forecast, !forecast.isEmpty {
                LazyVStack(spacing: 8) {
                    ForEach(forecast, id: \.dt) { item in
                        HStack {
                            Text(dayFormatter.string(from: Date(timeIntervalSince1970: item.dt)))
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(width: 60, alignment: .leading)
                            
                            if let icon = item.weather.first?.icon {
                                Image(systemName: viewModel.mapIcon(code: icon))
                                    .symbolRenderingMode(.multicolor)
                                    .font(.title3)
                            }
                            
                            Spacer()
                            
                            Text(viewModel.formattedTemp(item.main.temp))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(
                            reduceTransparency ? Color.white.opacity(0.10) : .thinMaterial,
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(colorScheme == .dark ? 0.14 : 0.10), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.08), radius: 10, y: 6)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.85)
                                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Forecast",
                    systemImage: "cloud.sun",
                    description: Text("Search for a city to load weather forecast")
                )
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}

