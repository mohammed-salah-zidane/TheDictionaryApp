//
//  WordDefinitionMapperTests.swift
//  Data
//
//  Created by Mohamed Salah on 27/02/2025.
//


import XCTest
import CoreData
@testable import Data
@testable import Domain

// MARK: - WordDefinitionMapperTests

final class WordDefinitionMapperTests: XCTestCase {
    func testMapToDomain() {
        let dto = WordDefinitionDTO(
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
        
        let domainModel = WordDefinitionMapper.mapToDomain(dto: dto)
        XCTAssertNotNil(domainModel)
        XCTAssertEqual(domainModel?.word, "hello")
        XCTAssertEqual(domainModel?.meanings.first?.partOfSpeech, "noun")
    }
    
    func testMapToDTO() {
        let domainModel = WordDefinition.dummy(word: "hello")
        let dto = WordDefinitionMapper.mapToDTO(domainModel: domainModel)
        XCTAssertEqual(dto.word, "hello")
        XCTAssertEqual(dto.meanings.first?.partOfSpeech, "noun")
    }
}