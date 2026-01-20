//
//  SearchViewModel.swift
//  Glasscast
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet {
            // Sync with query for backward compatibility
            query = searchText
        }
    }
    @Published var query: String = "" {
        didSet {
            // Sync with searchText
            if searchText != query {
                searchText = query
            }
        }
    }
    @Published var searchResults: [CitySearchResult] = []
    @Published var savedCities: [SavedCity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var searchCancellable: AnyCancellable?
    private let weatherService: WeatherService
    private let supabaseManager: SupabaseManager
    
    init(
        weatherService: WeatherService = .shared,
        supabaseManager: SupabaseManager = .shared
    ) {
        self.weatherService = weatherService
        self.supabaseManager = supabaseManager
        
        // Debounce search input
        searchCancellable = $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task { @MainActor in
                    await self?.performSearch()
                }
            }
    }
    
    func performSearch() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await weatherService.searchCity(query: trimmed)
            searchResults = results
        } catch {
            errorMessage = (error as? WeatherError)?.localizedDescription ?? error.localizedDescription
            searchResults = []
        }
        
        isLoading = false
    }
    
    func save(city: CitySearchResult) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabaseManager.saveFavorite(city: city)
            await loadFavorites()
            // Clear search results after saving
            searchResults = []
            query = ""
        } catch {
            errorMessage = error.localizedDescription
            print("Error saving city: \(error)")
        }
        
        isLoading = false
    }
    
    func delete(city: SavedCity) async {
        do {
            try await supabaseManager.deleteFavorite(city: city)
            await loadFavorites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            savedCities = try await supabaseManager.fetchFavorites()
            print("Loaded \(savedCities.count) favorite cities")
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading favorites: \(error)")
            savedCities = []
        }
        
        isLoading = false
    }
}
