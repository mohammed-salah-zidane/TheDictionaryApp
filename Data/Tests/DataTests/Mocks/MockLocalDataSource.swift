//
//  MockLocalDataSource.swift
//  DataTests
//
//  Created by Mohamed Salah on 27/02/2025.
//

import Foundation
@testable import Data
@testable import Domain

final class MockLocalDataSource: LocalDataSourceProtocol, @unchecked Sendable {
    var cachedDefinitions: [String: WordDefinition] = [:]
    var shouldSimulateError = false
    var error: Error = NSError(domain: "MockError", code: 0)
    
    func getCachedDefinition(for word: String) async throws -> WordDefinition? {
        if shouldSimulateError { throw error }
        return cachedDefinitions[word.lowercased()]
    }
    
    func cacheDefinition(_ definition: WordDefinition) async throws {
        if shouldSimulateError { throw error }
        cachedDefinitions[definition.word.lowercased()] = definition
    }
    
    func getPastSearches() async throws -> [WordDefinition] {
        if shouldSimulateError { throw error }
        return Array(cachedDefinitions.values)
    }
}

