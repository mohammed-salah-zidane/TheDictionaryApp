//
//  WordDefinitionRepositoryImpl.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Domain

public final class WordDefinitionRepositoryImpl: WordDefinitionRepository {
    private let remoteDataSource: RemoteDataSourceProtocol
    private let localDataSource: LocalDataSourceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    public init(
        remoteDataSource: RemoteDataSourceProtocol = RemoteDataSource(),
        localDataSource: LocalDataSourceProtocol = LocalDataSource(),
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor()
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }
    
    public func fetchDefinition(for word: String) async throws -> WordDefinition {
        // First try to get from cache
        if let cachedDefinition = try? await localDataSource.getCachedDefinition(for: word) {
            return cachedDefinition
        }
        
        // Wait for network connectivity with a 10-second timeout
        let isConnected = await networkMonitor.waitForConnection(timeout: 10.0)
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        do {
            let definitions = try await remoteDataSource.fetchDefinition(for: word)
            guard let definition = definitions.first else {
                throw NetworkError.notFound
            }
            
            // Cache the successful result
            try? await localDataSource.cacheDefinition(definition)
            return definition
            
        } catch let error as NetworkError {
            switch error {
            case .notFound:
                throw NetworkError.notFound
            case .noInternetConnection:
                throw NetworkError.noInternetConnection
            case .invalidResponse, .decodingFailed:
                throw NetworkError.invalidResponse
            case .requestFailed(let statusCode, _):
                if statusCode == 404 {
                    throw NetworkError.notFound
                } else if statusCode >= 500 {
                    throw NetworkError.requestFailed(statusCode: statusCode, data: nil)
                }
                throw error
            case .timeout:
                throw NetworkError.timeout
            case .invalidURL, .cancelled:
                throw error
            case .unknown(let underlyingError):
                throw NetworkError.unknown(underlyingError)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    public func getCachedDefinition(for word: String) async throws -> WordDefinition? {
        try await localDataSource.getCachedDefinition(for: word)
    }
    
    public func cacheDefinition(_ definition: WordDefinition) async throws {
        try await localDataSource.cacheDefinition(definition)
    }
    
    public func getPastSearches() async throws -> [WordDefinition] {
        try await localDataSource.getPastSearches()
    }
}
