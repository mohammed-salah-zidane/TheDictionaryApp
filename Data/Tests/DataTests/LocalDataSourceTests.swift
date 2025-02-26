//
//  LocalDataSourceTests.swift
//  Data
//
//  Created by Mohamed Salah on 27/02/2025.
//


import XCTest
import CoreData
@testable import Data
@testable import Domain

// MARK: - LocalDataSourceTests
final class LocalDataSourceTests: XCTestCase {
    private var coreDataStack: CoreDataStack!
    private var localDataSource: LocalDataSource!
    
    override func setUp() {
        super.setUp()
        // Create an in-memory CoreDataStack
        coreDataStack = CoreDataStack(inMemory: true)
        
        // Inject it into the LocalDataSource
        localDataSource = LocalDataSource(coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        coreDataStack = nil
        localDataSource = nil
        super.tearDown()
    }
    
    func testCacheAndRetrieveDefinition() async throws {
        let definition = WordDefinition.dummy(word: "hello")
        try await localDataSource.cacheDefinition(definition)
        
        let fetchedDefinition = try await localDataSource.getCachedDefinition(for: "hello")
        XCTAssertNotNil(fetchedDefinition)
        XCTAssertEqual(fetchedDefinition?.word, definition.word)
    }
    
    func testGetPastSearches() async throws {
        // Initially, the cache should be empty.
        var searches = try await localDataSource.getPastSearches()
        XCTAssertTrue(searches.isEmpty)
        
        // Cache two definitions.
        let def1 = WordDefinition.dummy(word: "hello")
        let def2 = WordDefinition.dummy(word: "world")
        try await localDataSource.cacheDefinition(def1)
        try await localDataSource.cacheDefinition(def2)
        
        searches = try await localDataSource.getPastSearches()
        XCTAssertEqual(searches.count, 2)
        // The most recent search (cached later) should be first.
        XCTAssertEqual(searches.first?.word, "world")
    }
}
