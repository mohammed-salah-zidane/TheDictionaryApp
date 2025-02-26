//
//  WordDefinitionRepositoryImplTests.swift
//  Data
//
//  Created by Mohamed Salah on 27/02/2025.
//

import XCTest
import CoreData
@testable import Data
@testable import Domain

// MARK: - WordDefinitionRepositoryImplTests

final class WordDefinitionRepositoryImplTests: XCTestCase {
    private var repository: MockWordDefinitionRepository!
    
    override func setUp() {
        super.setUp()
        repository = MockWordDefinitionRepository()
    }
    
    override func tearDown() {
        repository.reset()
        repository = nil
        super.tearDown()
    }
        
    private func makeDummyDefinition(word: String = "hello") -> WordDefinition {
        WordDefinition.dummy(word: word)
    }
    
    func testFetchDefinition_WhenWordExists_ShouldReturnDefinition() async throws {
        // Given
        let definition = makeDummyDefinition()
        try await repository.cacheDefinition(definition)
        
        // When
        let result = try await repository.fetchDefinition(for: "hello")
        
        // Then
        XCTAssertEqual(result.word, "hello")
        XCTAssertEqual(repository.fetchDefinitionCallCount, 1)
    }
    
    func testFetchDefinition_WithEmptyWord_ShouldThrowInvalidInput() async {
        // Given
        let emptyWord = "   "
        
        // When/Then
        do {
            _ = try await repository.fetchDefinition(for: emptyWord)
            XCTFail("Expected RepositoryError.invalidInput")
        } catch let error as RepositoryError {
            guard case .invalidInput = error else {
                XCTFail("Expected invalidInput error, got \(error)")
                return
            }
        } catch {
            XCTFail("Expected RepositoryError.invalidInput, got \(error)")
        }
        XCTAssertEqual(repository.fetchDefinitionCallCount, 1)
    }
    
    func testFetchDefinition_WhenWordNotFound_ShouldThrowNoDataFound() async {
        // Given
        repository.shouldSimulateError = false
        
        // When/Then
        do {
            _ = try await repository.fetchDefinition(for: "unknown")
            XCTFail("Expected RepositoryError.noDataFound")
        } catch let error as RepositoryError {
            guard case .noDataFound = error else {
                XCTFail("Expected noDataFound error, got \(error)")
                return
            }
        } catch {
            XCTFail("Expected RepositoryError.noDataFound, got \(error)")
        }
        XCTAssertEqual(repository.fetchDefinitionCallCount, 1)
    }
    
    func testFetchDefinition_WhenErrorOccurs_ShouldThrowError() async {
        // Given
        repository.shouldSimulateError = true
        repository.error = RepositoryError.serverError
        
        // When/Then
        do {
            _ = try await repository.fetchDefinition(for: "hello")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? RepositoryError, RepositoryError.serverError)
        }
        XCTAssertEqual(repository.fetchDefinitionCallCount, 1)
    }
    
    func testGetCachedDefinition_WhenExists_ShouldReturnDefinition() async throws {
        // Given
        let definition = makeDummyDefinition()
        try await repository.cacheDefinition(definition)
        
        // When
        let result = try await repository.getCachedDefinition(for: "hello")
        
        // Then
        XCTAssertEqual(result?.word, "hello")
        XCTAssertEqual(repository.getCachedDefinitionCallCount, 1)
        XCTAssertEqual(repository.cacheDefinitionCallCount, 1)
    }
    
    func testGetCachedDefinition_WhenNotExists_ShouldReturnNil() async throws {
        // When
        let result = try await repository.getCachedDefinition(for: "unknown")
        
        // Then
        XCTAssertNil(result)
        XCTAssertEqual(repository.getCachedDefinitionCallCount, 1)
    }
    
    func testGetPastSearches_ShouldReturnAllDefinitions() async throws {
        // Given
        let definitions = [
            makeDummyDefinition(word: "hello"),
            makeDummyDefinition(word: "world")
        ]
        
        for definition in definitions {
            try await repository.cacheDefinition(definition)
        }
        
        // When
        let results = try await repository.getPastSearches()
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains { $0.word == "hello" })
        XCTAssertTrue(results.contains { $0.word == "world" })
        XCTAssertEqual(repository.getPastSearchesCallCount, 1)
        XCTAssertEqual(repository.cacheDefinitionCallCount, 2)
    }
    
    func testCacheDefinition_WhenErrorOccurs_ShouldThrowError() async {
        // Given
        repository.shouldSimulateError = true
        repository.error = RepositoryError.dataError("Failed to cache")
        
        // When/Then
        do {
            try await repository.cacheDefinition(makeDummyDefinition())
            XCTFail("Expected error to be thrown")
        } catch let error as RepositoryError {
            if case .dataError = error {
                // Test passed
            } else {
                XCTFail("Expected dataError, got \(error)")
            }
        } catch {
            XCTFail("Expected RepositoryError, got \(error)")
        }
        XCTAssertEqual(repository.cacheDefinitionCallCount, 1)
    }
}
