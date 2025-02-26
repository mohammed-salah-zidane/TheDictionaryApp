//
//  MockWordDefinitionRepository.swift
//  DataTests
//
//  Created by Mohamed Salah on 27/02/2025.
//

import Foundation
@testable import Domain
@testable import Data

final class MockWordDefinitionRepository: WordDefinitionRepository, @unchecked Sendable {
    // MARK: - Properties
    
    let remoteDataSource: RemoteDataSourceProtocol
    let localDataSource: LocalDataSourceProtocol
    
    var fetchDefinitionCallCount = 0
    var getCachedDefinitionCallCount = 0
    var cacheDefinitionCallCount = 0
    var getPastSearchesCallCount = 0
    
    var shouldSimulateError = false
    var error: Error = NSError(domain: "MockError", code: 0)
    
    // MARK: - Initialization
    
    init(remoteDataSource: RemoteDataSourceProtocol = MockRemoteDataSource(),
         localDataSource: LocalDataSourceProtocol = MockLocalDataSource()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    // MARK: - WordDefinitionRepository
    
    func fetchDefinition(for word: String) async throws -> WordDefinition {
        fetchDefinitionCallCount += 1
        
        if shouldSimulateError {
            throw error
        }
        
        let sanitizedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedWord.isEmpty else {
            throw RepositoryError.invalidInput("Word cannot be empty")
        }
        
        // Try remote first
        do {
            let definitions = try await remoteDataSource.fetchDefinition(for: sanitizedWord)
            guard let definition = definitions.first else {
                throw RepositoryError.noDataFound
            }
            // Cache successful result
            try await localDataSource.cacheDefinition(definition)
            return definition
        } catch {
            // On remote failure, try cache
            if let cached = try await localDataSource.getCachedDefinition(for: sanitizedWord) {
                return cached
            }
            throw RepositoryError.noDataFound
        }
    }
    
    func getCachedDefinition(for word: String) async throws -> WordDefinition? {
        getCachedDefinitionCallCount += 1
        if shouldSimulateError {
            throw error
        }
        return try await localDataSource.getCachedDefinition(for: word)
    }
    
    func cacheDefinition(_ definition: WordDefinition) async throws {
        cacheDefinitionCallCount += 1
        if shouldSimulateError {
            throw error
        }
        try await localDataSource.cacheDefinition(definition)
    }
    
    func getPastSearches() async throws -> [WordDefinition] {
        getPastSearchesCallCount += 1
        if shouldSimulateError {
            throw error
        }
        return try await localDataSource.getPastSearches()
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        fetchDefinitionCallCount = 0
        getCachedDefinitionCallCount = 0
        cacheDefinitionCallCount = 0
        getPastSearchesCallCount = 0
        shouldSimulateError = false
        
        // Reset mock data sources if they're our default mocks
        if let mockLocal = localDataSource as? MockLocalDataSource {
            mockLocal.cachedDefinitions.removeAll()
        }
        if let mockRemote = remoteDataSource as? MockRemoteDataSource {
            mockRemote.result = nil
        }
    }
}
