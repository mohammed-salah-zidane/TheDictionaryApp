//
//  RemoteDataSourceProtocol.swift
//  Domain
//
//  Created by Mohamed Salah on 27/02/2025.
//


import Foundation

/// Protocol defining operations for remote fetching of word definitions
public protocol RemoteDataSourceProtocol: Sendable {
    /// Fetches definition data for a word from the remote API
    /// - Parameter word: The word to fetch the definition for
    /// - Returns: Array of word definitions from the API
    /// - Throws: NetworkError if the request fails
    func fetchDefinition(for word: String) async throws -> [Domain.WordDefinition]
}
