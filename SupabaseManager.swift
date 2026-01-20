//
//  SupabaseManager.swift
//  Glasscast
//
//  Supabase client configuration and auth access
//

import Foundation
import Supabase

/// Singleton Supabase client manager
final class SupabaseManager {
	static let shared = SupabaseManager()
	
	let client: SupabaseClient
	
	/// Current authenticated user (if a session exists).
	var user: User? {
		client.auth.currentSession?.user
	}
	
	private init() {
		guard let url = URL(string: Secrets.supabaseURL) else {
			fatalError("Invalid Supabase URL in Secrets.swift")
		}
		
		self.client = SupabaseClient(
			supabaseURL: url,
			supabaseKey: Secrets.supabaseKey
		)
	}
	
	/// Save a favorite city to the database
	func saveFavorite(city: CitySearchResult) async throws {
		guard let userId = user?.id else {
			throw NSError(domain: "SupabaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
		}
		
		struct FavoriteCityInsert: Encodable {
			let userId: String
			let cityName: String
			let lat: Double
			let lon: Double
			
			enum CodingKeys: String, CodingKey {
				case userId = "user_id"
				case cityName = "city_name"
				case lat
				case lon
			}
		}
		
		let favorite = FavoriteCityInsert(
			userId: userId.uuidString,
			cityName: city.name,
			lat: city.lat,
			lon: city.lon
		)
		
		try await client.database
			.from("favorite_cities")
			.insert(favorite)
			.execute()
	}
	
	/// Fetch all favorite cities for the current user
	func fetchFavorites() async throws -> [SavedCity] {
		guard let userId = user?.id else {
			throw NSError(domain: "SupabaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
		}
		
		do {
			let response: [SavedCity] = try await client.database
				.from("favorite_cities")
				.select("user_id, city_name, lat, lon, created_at")
				.eq("user_id", value: userId.uuidString)
				.order("created_at", ascending: false)
				.execute()
				.value
			
			print("Successfully fetched \(response.count) favorites")
			return response
		} catch {
			print("Error fetching favorites: \(error)")
			if let error = error as NSError? {
				print("Error domain: \(error.domain), code: \(error.code)")
				print("Error description: \(error.localizedDescription)")
			}
			throw error
		}
	}
	
	/// Delete a favorite city
	func deleteFavorite(city: SavedCity) async throws {
		guard let userId = user?.id else {
			throw NSError(domain: "SupabaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
		}
		
		// Delete by matching user_id, city_name, lat, and lon since there's no id column
		try await client.database
			.from("favorite_cities")
			.delete()
			.eq("user_id", value: userId.uuidString)
			.eq("city_name", value: city.cityName)
			.eq("lat", value: city.lat)
			.eq("lon", value: city.lon)
			.execute()
	}
}
