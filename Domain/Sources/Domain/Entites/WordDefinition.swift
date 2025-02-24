//
//  WordDefinition.swift
//  Domain
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation

// Represents the definition for a word.
public struct WordDefinition: Codable, Equatable, Sendable {
    public let word: String
    public let phonetic: String?
    public let phonetics: [Phonetic]
    public let origin: String?
    public let meanings: [Meaning]
    
    public init(word: String, phonetic: String?, phonetics: [Phonetic], origin: String?, meanings: [Meaning]) {
        self.word = word
        self.phonetic = phonetic
        self.phonetics = phonetics
        self.origin = origin
        self.meanings = meanings
    }
}

public struct Phonetic: Codable, Equatable, Sendable {
    public let text: String?
    public let audio: String?
    
    public init(text: String?, audio: String?) {
        self.text = text
        self.audio = audio
    }
}

public struct Meaning: Codable, Equatable, Sendable {
    public let partOfSpeech: String
    public let definitions: [Definition]
    
    public init(partOfSpeech: String, definitions: [Definition]) {
        self.partOfSpeech = partOfSpeech
        self.definitions = definitions
    }
}

public struct Definition: Codable, Equatable, Sendable {
    public let definition: String
    public let example: String?
    public let synonyms: [String]
    public let antonyms: [String]
    
    public init(definition: String, example: String?, synonyms: [String], antonyms: [String]) {
        self.definition = definition
        self.example = example
        self.synonyms = synonyms
        self.antonyms = antonyms
    }
}
