//
//  AuthViewModel.swift
//  Glasscast
//

import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient = SupabaseManager.shared.client) {
        self.supabase = supabase
        self.isAuthenticated = SupabaseManager.shared.user != nil
    }
    
    func signUp() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await supabase.auth.signUp(email: email, password: password)
                self.isAuthenticated = SupabaseManager.shared.user != nil
            } catch {
                self.errorMessage = "Could not create account. Please check your email/password and try again."
            }
            self.isLoading = false
        }
    }
    
    func signIn() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await supabase.auth.signIn(email: email, password: password)
                self.isAuthenticated = SupabaseManager.shared.user != nil
            } catch {
                self.errorMessage = "Sign in failed. Please verify your credentials and try again."
            }
            self.isLoading = false
        }
    }
    
    func signOut() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await supabase.auth.signOut()
                self.isAuthenticated = false
            } catch {
                self.errorMessage = "Could not sign out. Please try again."
            }
            self.isLoading = false
        }
    }
}

