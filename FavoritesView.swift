//
//  FavoritesView.swift
//  Glasscast
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedCity: SavedCity?
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark ? [.black, .indigo, .blue] : [.pink.opacity(0.6), .purple.opacity(0.5), .blue.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(0.16)
                
                Group {
                    if viewModel.savedCities.isEmpty {
                        ContentUnavailableView(
                            "No Favorites",
                            systemImage: "heart.slash",
                            description: Text("Use the Search tab to add favorite cities.")
                        )
                    } else {
                        List {
                            Section("My Favorites") {
                                ForEach(viewModel.savedCities) { city in
                                    Button {
                                        selectedCity = city
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "heart.fill")
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(.pink)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(city.cityName)
                                                    .font(.body.weight(.semibold))
                                                    .foregroundStyle(.primary)
                                                
                                                Text("\(city.lat, specifier: "%.2f"), \(city.lon, specifier: "%.2f")")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Task {
                                                await viewModel.delete(city: city)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Favorites")
            .task {
                await viewModel.loadFavorites()
            }
            .onChange(of: selectedCity) { oldValue, newValue in
                if let city = newValue {
                    // Navigate to home with selected city
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SelectedCity"),
                        object: city
                    )
                }
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(AuthViewModel())
    }
}
