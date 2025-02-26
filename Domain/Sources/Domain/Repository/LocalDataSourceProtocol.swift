//
//  LocalDataSourceProtocol.swift
//  Domain
//
//  Created by Mohamed Salah on 27/02/2025.
//


import Foundation

/// Protocol defining operations for local storage of word definitions
public protocol LocalDataSourceProtocol: Sendable {
    /// Retrieves a cached definition for the specified word if available
    /// - Parameter word: The word to look up
    /// - Returns: A WordDefinition if found, nil otherwise
    func getCachedDefinition(for word: String) async throws -> WordDefinition?
    
    /// Caches a word definition for future retrieval
    /// - Parameter definition: The WordDefinition to cache
    func cacheDefinition(_ definition: WordDefinition) async throws
    
    /// Retrieves all previously cached word definitions
    /// - Returns: An array of WordDefinition objects, sorted by most recent first
    func getPastSearches() async throws -> [WordDefinition]
}
