//
//  ContentView.swift
//  Glasscast
//

import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if auth.isAuthenticated {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        HomeView()
                            .navigationTitle("Weather")
                            .navigationBarTitleDisplayMode(.large)
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                    
                    NavigationStack {
                        FavoritesView()
                            .navigationTitle("Favorites")
                    }
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                    .tag(1)
                    
                    NavigationStack {
                        SearchView(viewModel: searchViewModel)
                            .navigationTitle("Search")
                    }
                    .searchable(
                        text: $searchViewModel.searchText,
                        prompt: "Search locations..."
                    )
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(2)
                    
                    NavigationStack {
                        SettingsView()
                            .navigationTitle("Settings")
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SelectedCity"))) { _ in
                    // Switch to Home tab when a city is selected
                    selectedTab = 0
                }
            } else {
                AuthView()
            }
        }
        .environmentObject(auth)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

