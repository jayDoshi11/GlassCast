//
//  Secrets.swift
//  Glasscast
//
//  IMPORTANT: This file contains sensitive API keys and should NEVER be committed to version control.
//  Add your actual API keys here for local development.
//

import Foundation

struct Secrets {
    /// Supabase project URL
    static let supabaseURL: String = "qqqqrgtjhdiicetrwcem"
    
    /// Supabase anonymous key
    static let supabaseAnonKey: String = "jakpym-7puQja-janvyq"

    /// Alias for docs/code that refer to `supabaseKey`
    static var supabaseKey: String { supabaseAnonKey }
    
    /// OpenWeatherMap API key
    static let weatherAPIKey: String = "8ec04f7099f1813adda337f3f763e3e2"
}
