//
//  WordDefinitionRepository.swift
//  Domain
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation

// Protocol defining methods for fetching and caching word definitions.
public protocol WordDefinitionRepository {
    func fetchDefinition(for word: String) async throws -> WordDefinition
    func getCachedDefinition(for word: String) async throws -> WordDefinition?
    func cacheDefinition(_ definition: WordDefinition) async throws
    func getPastSearches() async throws -> [WordDefinition]
}
