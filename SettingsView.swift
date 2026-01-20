//
//  SettingsView.swift
//  Glasscast
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var unitManager = UnitManager.shared
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // UI-only theme preference (stored). Note: applying it app-wide requires `.preferredColorScheme(...)`
    // at the app root (e.g. ContentView/GlasscastApp), which is outside this View file.
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Appearance", systemImage: "paintpalette.fill")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ThemeCard(mode: .light, isSelected: appearanceMode == .light)
                                .onTapGesture {
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.72)) {
                                        appearanceMode = .light
                                    }
                                }
                            
                            ThemeCard(mode: .system, isSelected: appearanceMode == .system)
                                .onTapGesture {
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.72)) {
                                        appearanceMode = .system
                                    }
                                }
                            
                            ThemeCard(mode: .dark, isSelected: appearanceMode == .dark)
                                .onTapGesture {
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.72)) {
                                        appearanceMode = .dark
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 2)
                    }
                    .padding(.vertical, 6)
                }
                
                Section("Preferences") {
                    Picker("Temperature Unit", selection: $unitManager.isMetric) {
                        Text("Celsius").tag(true)
                        Text("Fahrenheit").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Account") {
                    if let userEmail = SupabaseManager.shared.user?.email {
                        HStack {
                            Label("Email", systemImage: "envelope.fill")
                            Spacer()
                            Text(userEmail)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        auth.signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}

// MARK: - UI-only Appearance Mode

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .light:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .system:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .dark:
            return LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

private struct ThemeCard: View {
    let mode: AppearanceMode
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(mode.gradient)
                    .frame(width: 92, height: 112)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.white : Color.white.opacity(0.20), lineWidth: isSelected ? 3 : 1)
                    }
                    .shadow(color: .black.opacity(isSelected ? 0.18 : 0.10), radius: isSelected ? 12 : 8, y: 6)
                
                VStack(spacing: 8) {
                    Image(systemName: mode.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                        .symbolEffect(isSelected ? .bounce : .none, value: isSelected)
                    
                    Text(mode.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isSelected)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
