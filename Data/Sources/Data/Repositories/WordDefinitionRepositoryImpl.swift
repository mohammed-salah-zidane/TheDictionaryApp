//
//  WordDefinitionRepositoryImpl.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import Domain

public class WordDefinitionRepositoryImpl: WordDefinitionRepository {
    private let remoteDataSource: RemoteDataSourceProtocol
    private let localDataSource: LocalDataSourceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    public init(remoteDataSource: RemoteDataSourceProtocol = RemoteDataSource(),
                localDataSource: LocalDataSourceProtocol = LocalDataSource(),
                networkMonitor: NetworkMonitorProtocol = NetworkMonitor.shared) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }
    
    public func fetchDefinition(for word: String) async throws -> WordDefinition {
        if networkMonitor.isConnected {
            do {
                let remoteDefinitions = try await remoteDataSource.fetchDefinition(for: word)
                if let definition = WordDefinitionMapper.map(apiResponse: remoteDefinitions) {
                    try await localDataSource.cacheDefinition(definition)
                    return definition
                } else {
                    throw NSError(domain: "No definition found", code: 0)
                }
            } catch {
                if let cached = try await localDataSource.getCachedDefinition(for: word) {
                    return cached
                }
                throw error
            }
        } else {
            if let cached = try await localDataSource.getCachedDefinition(for: word) {
                return cached
            } else {
                throw NSError(domain: "No internet connection and no cached data", code: -1)
            }
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
