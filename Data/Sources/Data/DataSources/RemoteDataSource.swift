//
//  RemoteDataSourceProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Domain

/// Implementation of RemoteDataSourceProtocol using NetworkClient
public final class RemoteDataSource: RemoteDataSourceProtocol {
    private let networkClient: NetworkClientProtocol
    
    public init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    public func fetchDefinition(for word: String) async throws -> [Domain.WordDefinition] {
        // Sanitize input by trimming whitespace and ensuring proper encoding
        let sanitizedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedWord.isEmpty else {
            throw NetworkError.invalidRequest("Word cannot be empty")
        }
        
        // Use our custom endpoint
        let endpoint = DictionaryEndpoints.fetchDefinition(word: sanitizedWord)
        
        // 1. Fetch the DTO response
        let apiResponseDTOs: [WordDefinitionDTO] = try await networkClient.request(endpoint)
        
        // 2. Map DTOs to domain models using the mapper
        let domainModels = WordDefinitionMapper.mapToDomain(apiResponse: apiResponseDTOs)
        
        guard !domainModels.isEmpty else {
            throw NetworkError.decodingFailed(NSError(domain: "RemoteDataSource", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to map API response to domain models"]))
        }
        
        // 3. Return the domain models
        return domainModels
    }
}
