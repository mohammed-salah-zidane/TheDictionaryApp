//
//  WordDefinitionRepository.swift
//  Domain
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

/// Protocol defining the boundary between domain and data layers for dictionary operations.
/// This follows the Repository pattern to abstract the data source implementation details.
public protocol WordDefinitionRepository: Sendable {
    /// Fetches a word definition from either local cache or remote API
    /// - Parameter word: The word to look up
    /// - Returns: The complete word definition
    /// - Throws: Repository errors including network, data, or not found errors
    func fetchDefinition(for word: String) async throws -> WordDefinition
    
    /// Retrieves a definition from the local cache only
    /// - Parameter word: The word to look up in cache
    /// - Returns: The cached definition if available, nil otherwise
    /// - Throws: Repository errors related to local storage operations
    func getCachedDefinition(for word: String) async throws -> WordDefinition?
    
    /// Stores a definition in the local cache
    /// - Parameter definition: The WordDefinition to cache
    /// - Throws: Repository errors related to local storage operations
    func cacheDefinition(_ definition: WordDefinition) async throws
    
    /// Retrieves all previously searched and cached word definitions
    /// - Returns: Array of WordDefinition objects
    /// - Throws: Repository errors related to local storage operations
    func getPastSearches() async throws -> [WordDefinition]
}
