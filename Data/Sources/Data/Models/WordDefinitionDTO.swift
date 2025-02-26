//
//  WordDefinitionDTO.swift
//  Data
//
//  Created by Mohamed Salah on 25/02/2025.
//

import Foundation

/// Data Transfer Object representing the API response structure from dictionaryapi.dev
public struct WordDefinitionDTO: Codable, Sendable {
    /// The word being defined
    public let word: String
    
    /// The phonetic notation for pronunciation (may be nil if unavailable)
    public let phonetic: String?
    
    /// Collection of phonetic representations with optional audio pronunciations
    public let phonetics: [PhoneticDTO]
    
    /// Etymology information about the word's origin (may be nil if unavailable)
    public let origin: String?
    
    /// Collection of different meanings grouped by part of speech
    public let meanings: [MeaningDTO]
    
    public init(word: String, phonetic: String?, phonetics: [PhoneticDTO], origin: String?, meanings: [MeaningDTO]) {
        self.word = word
        self.phonetic = phonetic
        self.phonetics = phonetics
        self.origin = origin
        self.meanings = meanings
    }
}

/// Represents a phonetic notation with optional audio pronunciation in the API response
public struct PhoneticDTO: Codable, Sendable {
    /// The phonetic text representation (IPA notation)
    public let text: String?
    
    /// URL string for audio pronunciation (may be nil if unavailable)
    public let audio: String?
    
    public init(text: String?, audio: String?) {
        self.text = text
        self.audio = audio
    }
}

/// Represents a collection of definitions for a specific part of speech in the API response
public struct MeaningDTO: Codable, Sendable {
    /// The grammatical category (noun, verb, adjective, etc.)
    public let partOfSpeech: String
    
    /// Collection of definitions for this part of speech
    public let definitions: [DefinitionDTO]
    
    public init(partOfSpeech: String, definitions: [DefinitionDTO]) {
        self.partOfSpeech = partOfSpeech
        self.definitions = definitions
    }
}

/// Represents a single definition with examples and related words in the API response
public struct DefinitionDTO: Codable, Sendable {
    /// The actual definition text
    public let definition: String
    
    /// Optional example usage of the word
    public let example: String?
    
    /// Collection of words with similar meanings
    public let synonyms: [String]
    
    /// Collection of words with opposite meanings
    public let antonyms: [String]
    
    public init(definition: String, example: String?, synonyms: [String], antonyms: [String]) {
        self.definition = definition
        self.example = example
        self.synonyms = synonyms
        self.antonyms = antonyms
    }
}
