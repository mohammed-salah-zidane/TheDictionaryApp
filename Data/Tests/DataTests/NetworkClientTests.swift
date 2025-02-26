//
//  NetworkClientTests.swift
//  Data
//
//  Created by Mohamed Salah on 27/02/2025.
//


import XCTest
import CoreData
@testable import Data
@testable import Domain

// MARK: - NetworkClientTests

final class NetworkClientTests: XCTestCase {
    private var mockNetworkClient: MockNetworkClient!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
    }
    
    override func tearDown() {
        mockNetworkClient = nil
        super.tearDown()
    }
    
    func testNetworkClientSuccess() async throws {
        // Prepare dummy JSON data for a WordDefinitionDTO array
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
        
        // Set success response
        mockNetworkClient.result = .success([dummyDTO])
        
        let endpoint = DictionaryEndpoints.fetchDefinition(word: "hello")
        let result: [WordDefinitionDTO] = try await mockNetworkClient.request(endpoint)
        XCTAssertEqual(result.first?.word, "hello")
    }
    
    func testNetworkClient404() async {
        // Set 404 error response
        mockNetworkClient.result = .failure(NetworkError.notFound)
        
        let endpoint = DictionaryEndpoints.fetchDefinition(word: "nonexistent")
        do {
            let _: [WordDefinitionDTO] = try await mockNetworkClient.request(endpoint)
            XCTFail("Expected NetworkError.notFound")
        } catch let error as NetworkError {
            switch error {
            case .notFound:
                // Correct error
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
