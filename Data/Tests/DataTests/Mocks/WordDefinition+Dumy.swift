//
//  WordDefinition+Dumy.swift
//  Data
//
//  Created by Mohamed Salah on 27/02/2025.
//

import XCTest
@testable import Data
@testable import Domain

// Provide a helper to create a dummy word definition for testing.
extension WordDefinition {
    static func dummy(word: String = "hello") -> WordDefinition {
        WordDefinition(
            word: word,
            phonetic: "həˈləʊ",
            phonetics: [Phonetic(text: "həˈləʊ", audio: "http://audio.url")],
            origin: "Old English",
            meanings: [
                Meaning(
                    partOfSpeech: "noun",
                    definitions: [
                        Definition(
                            definition: "A greeting",
                            example: "Hello there!",
                            synonyms: [],
                            antonyms: []
                        )
                    ]
                )
            ]
        )
    }
}
