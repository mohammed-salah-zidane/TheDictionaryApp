//
//  FetchWordDefinitionUseCase.swift
//  Domain
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

public protocol FetchWordDefinitionUseCase: Sendable {
    func execute(for word: String) async throws -> WordDefinition
}
// Use case to fetch a word definition.
public struct DefaultFetchWordDefinitionUseCase: FetchWordDefinitionUseCase {
    private let repository: WordDefinitionRepository
    
    public init(repository: WordDefinitionRepository) {
        self.repository = repository
    }
    
    public func execute(for word: String) async throws -> WordDefinition {
        // The repository is responsible for checking network connectivity and caching.
        return try await repository.fetchDefinition(for: word)
    }
}
