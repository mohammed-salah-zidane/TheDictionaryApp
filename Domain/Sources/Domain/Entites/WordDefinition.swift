//
//  WordDefinition.swift
//  Domain
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

/// Represents a complete definition for a word with all its meanings and phonetic information.
/// This is the core domain entity that represents dictionary content.
public struct WordDefinition: Codable, Equatable, Sendable, Identifiable {
    public var id: String {
        return word
    }

    /// The word being defined
    public let word: String
    
    /// The phonetic notation for pronunciation (may be nil if unavailable)
    public let phonetic: String?
    
    /// Collection of phonetic representations with optional audio pronunciations
    public let phonetics: [Phonetic]
    
    /// Etymology information about the word's origin (may be nil if unavailable)
    public let origin: String?
    
    /// Collection of different meanings grouped by part of speech
    public let meanings: [Meaning]
    
    /// Creates a new WordDefinition with all properties
    /// - Parameters:
    ///   - word: The word being defined
    ///   - phonetic: Optional phonetic notation
    ///   - phonetics: Array of phonetic representations
    ///   - origin: Optional etymology information
    ///   - meanings: Array of meanings organized by part of speech
    public init(word: String, phonetic: String?, phonetics: [Phonetic], origin: String?, meanings: [Meaning]) {
        self.word = word
        self.phonetic = phonetic
        self.phonetics = phonetics
        self.origin = origin
        self.meanings = meanings
    }
}

/// Represents a phonetic notation with optional audio pronunciation
public struct Phonetic: Codable, Equatable, Sendable {
    /// The phonetic text representation (IPA notation)
    public let text: String?
    
    /// URL string for audio pronunciation (may be nil if unavailable)
    public let audio: String?
    
    /// Creates a new Phonetic instance
    /// - Parameters:
    ///   - text: The phonetic text representation
    ///   - audio: Optional URL string for audio pronunciation
    public init(text: String?, audio: String?) {
        self.text = text
        self.audio = audio
    }
}

/// Represents a collection of definitions for a specific part of speech
public struct Meaning: Codable, Equatable, Sendable {
    /// The grammatical category (noun, verb, adjective, etc.)
    public let partOfSpeech: String
    
    /// Collection of definitions for this part of speech
    public let definitions: [Definition]
    
    /// Creates a new Meaning instance
    /// - Parameters:
    ///   - partOfSpeech: The grammatical category
    ///   - definitions: Array of definitions
    public init(partOfSpeech: String, definitions: [Definition]) {
        self.partOfSpeech = partOfSpeech
        self.definitions = definitions
    }
}

/// Represents a single definition with examples and related words
public struct Definition: Codable, Equatable, Sendable {
    /// The actual definition text
    public let definition: String
    
    /// Optional example usage of the word
    public let example: String?
    
    /// Collection of words with similar meanings
    public let synonyms: [String]
    
    /// Collection of words with opposite meanings
    public let antonyms: [String]
    
    /// Creates a new Definition instance
    /// - Parameters:
    ///   - definition: The definition text
    ///   - example: Optional example usage
    ///   - synonyms: Array of synonyms
    ///   - antonyms: Array of antonyms
    public init(definition: String, example: String?, synonyms: [String], antonyms: [String]) {
        self.definition = definition
        self.example = example
        self.synonyms = synonyms
        self.antonyms = antonyms
    }
}
