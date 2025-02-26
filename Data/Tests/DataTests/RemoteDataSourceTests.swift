//
//  RemoteDataSourceTests.swift
//  Data
//
//  Created by Mohamed Salah on 27/02/2025.
//


import XCTest
import CoreData
@testable import Data
@testable import Domain

// MARK: - RemoteDataSourceTests

final class RemoteDataSourceTests: XCTestCase {
    private var mockNetworkClient: MockNetworkClient!
    private var remoteDataSource: RemoteDataSource!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        remoteDataSource = RemoteDataSource(networkClient: mockNetworkClient)
    }
    
    override func tearDown() {
        mockNetworkClient = nil
        remoteDataSource = nil
        super.tearDown()
    }
    
    func testFetchDefinitionSuccess() async throws {
        // Create a dummy DTO matching our dummy domain model.
        let dummyDTO = WordDefinitionDTO(
            word: "hello",
            phonetic: "həˈləʊ",
            phonetics: [PhoneticDTO(text: "həˈləʊ", audio: "http://audio.url")],
            origin: "Old English",
            meanings: [
                MeaningDTO(
                    partOfSpeech: "noun",
                    definitions: [
                        DefinitionDTO(
                            definition: "A greeting",
                            example: "Hello there!",
                            synonyms: [],
                            antonyms: []
                        )
                    ]
                )
            ]
        )
        
        mockNetworkClient.result = .success([dummyDTO])
        let definitions = try await remoteDataSource.fetchDefinition(for: "hello")
        XCTAssertFalse(definitions.isEmpty)
        XCTAssertEqual(definitions.first?.word, "hello")
    }
    
    func testFetchDefinitionEmptyResponse() async {
        mockNetworkClient.result = .success([])
        do {
            _ = try await remoteDataSource.fetchDefinition(for: "nonexistent")
            XCTFail("Expected error for empty response")
        } catch {
            // Expected error path.
        }
    }
}