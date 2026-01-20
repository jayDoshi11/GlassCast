//
//  SearchView.swift
//  Glasscast
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var didSelect = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark ? [.black, .indigo, .blue] : [.blue, .purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(0.18)
            
            Group {
                if viewModel.searchText.isEmpty {
                    if viewModel.savedCities.isEmpty {
                        emptyState
                    } else {
                        savedCitiesSection
                    }
                } else {
                    if viewModel.isLoading {
                        searchingState
                    } else if viewModel.searchResults.isEmpty {
                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text("Try searching for a city or zip code")
                        )
                    } else {
                        searchResultsList
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading && !viewModel.searchText.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .task {
            await viewModel.loadFavorites()
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
        .sensoryFeedback(.selection, trigger: didSelect)
    }
    
    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .symbolEffect(reduceMotion ? .none : .pulse, value: viewModel.savedCities.count)
                .padding(.bottom, 6)
            
            Text("Search Locations")
                .font(.title.weight(.bold))
            
            Text("Find weather for any city and save favorites for quick switching.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            
            ContentUnavailableView(
                "Start typing above",
                systemImage: "text.cursor",
                description: Text("Use the native search bar to search locations.")
            )
            .padding(.top, 8)
        }
        .padding()
    }
    
    private var searchingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
            Text("Searching…")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchResultsList: some View {
        List {
            Section {
                ForEach(viewModel.searchResults) { city in
                    Button {
                        Task {
                            await viewModel.save(city: city)
                            dismissSearch()
                            didSelect.toggle()
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                if let state = city.state, let country = city.country {
                                    Text("\(state), \(country)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else if let country = city.country {
                                    Text(country)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            } header: {
                if !viewModel.searchResults.isEmpty {
                    Text("\(viewModel.searchResults.count) results")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
    
    private var savedCitiesSection: some View {
        List {
            Section("My Cities") {
                ForEach(viewModel.savedCities) { city in
                    Button {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("SelectedCity"),
                            object: city
                        )
                        didSelect.toggle()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.cityName)
                                    .font(.body)
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView(viewModel: SearchViewModel())
                .navigationTitle("Search")
        }
        .searchable(text: .constant(""), prompt: "Search locations...")
    }
}
