//
//  FetchWordDefinitionUseCase.swift
//  Domain
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

/// Protocol defining the operation to fetch a word definition.
/// This is part of the application's use cases, representing a specific action.
public protocol FetchWordDefinitionUseCase: Sendable {
    /// Executes the use case to fetch a definition for the given word
    /// - Parameter word: The word to look up
    /// - Returns: The complete word definition
    /// - Throws: Errors from the repository layer
    func execute(for word: String) async throws -> WordDefinition
}

/// Default implementation of the FetchWordDefinitionUseCase protocol.
/// Uses a repository to fetch the definition data.
public struct DefaultFetchWordDefinitionUseCase: FetchWordDefinitionUseCase {
    private let repository: WordDefinitionRepository
    
    /// Initializes the use case with a repository dependency
    /// - Parameter repository: The repository that will provide word definitions
    public init(repository: WordDefinitionRepository) {
        self.repository = repository
    }
    
    public func execute(for word: String) async throws -> WordDefinition {
        // The repository is responsible for checking network connectivity and caching.
        return try await repository.fetchDefinition(for: word)
    }
}
