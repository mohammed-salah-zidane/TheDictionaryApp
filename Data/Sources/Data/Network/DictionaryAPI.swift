//
//  DictionaryAPI.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import Moya

public enum DictionaryAPI {
    case fetchDefinition(word: String)
}

extension DictionaryAPI: TargetType {
    public var baseURL: URL {
        // Base URL for the Dictionary API.
        return URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en")!
    }
    
    public var path: String {
        switch self {
        case .fetchDefinition(let word):
            return "/\(word)"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data {
        return Data() // Provide sample JSON for tests if needed.
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
}
