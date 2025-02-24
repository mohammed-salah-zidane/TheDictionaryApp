//
//  RemoteDataSourceProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import Domain

public protocol RemoteDataSourceProtocol: Sendable {
    func fetchDefinition(for word: String) async throws -> [WordDefinition]
}

public final class RemoteDataSource: RemoteDataSourceProtocol {
    private let networkClient: NetworkClientProtocol
    
    public init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    public func fetchDefinition(for word: String) async throws -> [WordDefinition] {
        // 1) Use our custom endpoint
        let endpoint = DictionaryEndpoints.fetchDefinition(word: word)
        
        // 2) Fetch raw [WordDefinition] directly, or if needed, fetch a "RemoteDictionaryResponse" and map it
        
        let response: [WordDefinition] = try await networkClient.request(endpoint)
        
        // 3) Return the decoded domain model array
        return response
    }
}
