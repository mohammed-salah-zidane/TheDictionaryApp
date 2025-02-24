//
//  DictionaryEndpoints.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

/// Defines endpoints for dictionaryapi.dev
public enum DictionaryEndpoints {
    case fetchDefinition(word: String)
}

extension DictionaryEndpoints: RequestConfigurable {
    public var baseURL: String {
        // Base URL for dictionaryapi.dev
        "https://api.dictionaryapi.dev/api/v2/entries/en"
    }
    
    public var path: String {
        switch self {
        case .fetchDefinition(let word):
            // Example: https://api.dictionaryapi.dev/api/v2/entries/en/hello
            return "/\(word)"
        }
    }
    
    public var method: HTTPMethod {
        .get
    }
    
    // If needed, override or supply a custom JSONDecoder here
    public var decoder: JSONDecoder? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }
}
