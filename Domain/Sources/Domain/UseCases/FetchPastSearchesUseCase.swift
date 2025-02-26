//
//  FetchPastSearchesUseCase.swift
//  Domain
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

/// Protocol defining the operation to retrieve past word searches.
/// This is part of the application's use cases, representing user history retrieval.
public protocol FetchPastSearchesUseCase: Sendable {
    /// Executes the use case to retrieve all previously searched words
    /// - Returns: Array of WordDefinition objects representing past searches
    /// - Throws: Errors from the repository layer
    func execute() async throws -> [WordDefinition]
}

/// Default implementation of the FetchPastSearchesUseCase protocol.
/// Uses a repository to fetch the history data.
public final class DefaultFetchPastSearchesUseCase: FetchPastSearchesUseCase {
    private let repository: WordDefinitionRepository
    
    /// Initializes the use case with a repository dependency
    /// - Parameter repository: The repository that will provide search history
    public init(repository: WordDefinitionRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> [WordDefinition] {
        return try await repository.getPastSearches()
    }
}
