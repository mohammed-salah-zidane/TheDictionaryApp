//
//  RemoteDataSourceProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import Moya
import Domain

public protocol RemoteDataSourceProtocol {
    func fetchDefinition(for word: String) async throws -> [WordDefinition]
}

public class RemoteDataSource: RemoteDataSourceProtocol {
    private let provider: MoyaProvider<DictionaryAPI>
    
    public init(provider: MoyaProvider<DictionaryAPI> = MoyaProvider<DictionaryAPI>()) {
        self.provider = provider
    }
    
    public func fetchDefinition(for word: String) async throws -> [WordDefinition] {
        let response = try await provider.requestAsync(.fetchDefinition(word: word))
        let definitions = try JSONDecoder().decode([WordDefinition].self, from: response.data)
        return definitions
    }
}
