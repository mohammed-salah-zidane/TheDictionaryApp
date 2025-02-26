//
//  WordDefinitionRepositoryImpl.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Domain

/// Implementation of the WordDefinitionRepository protocol that orchestrates
/// data fetching from remote and local sources with proper caching.
public final class WordDefinitionRepositoryImpl: WordDefinitionRepository {
    private let remoteDataSource: RemoteDataSourceProtocol
    private let localDataSource: LocalDataSourceProtocol
    
    public init(
        remoteDataSource: RemoteDataSourceProtocol = RemoteDataSource(),
        localDataSource: LocalDataSourceProtocol = LocalDataSource()
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    public func fetchDefinition(for word: String) async throws -> WordDefinition {
        // Sanitize input
        let sanitizedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedWord.isEmpty else {
            throw RepositoryError.invalidInput("Word cannot be empty")
        }
        
        // First try to get from cache
        do {
            if let cachedDefinition = try await localDataSource.getCachedDefinition(for: sanitizedWord) {
                return cachedDefinition
            }
        } catch {
            // Log cache error but continue to try remote fetch
            print("Cache error: \(error.localizedDescription)")
        }
        
        do {
            // Fetch from remote source
            let definitions = try await remoteDataSource.fetchDefinition(for: sanitizedWord)
            
            // Use the mapper to get the first definition
            guard let definition = definitions.first else {
                throw RepositoryError.noDataFound
            }
            
            // Cache the successful result asynchronously without blocking the return
            Task {
                try? await localDataSource.cacheDefinition(definition)
            }
            
            return definition
            
        } catch let error as NetworkError {
            // Map network errors to repository errors for domain layer
            if let cachedDefinition = try? await localDataSource.getCachedDefinition(for: sanitizedWord) {
                return cachedDefinition
            }
            switch error {
            case .notFound:
                throw RepositoryError.noDataFound
            case .noInternetConnection:
                throw RepositoryError.networkError(error)
            case .timeout:
                throw RepositoryError.networkError(error)
            case .invalidResponse, .decodingFailed:
                throw RepositoryError.dataError("Invalid or corrupted data")
            case .requestFailed(let statusCode, _):
                if statusCode == 404 {
                    throw RepositoryError.noDataFound
                } else if statusCode >= 500 {
                    throw RepositoryError.serverError
                } else {
                    throw RepositoryError.networkError(error)
                }
            case .invalidURL, .invalidRequest, .cancelled, .clientError, .serverError, .unknown:
                throw RepositoryError.networkError(error)
            }
        } catch {
            if let cachedDefinition = try? await localDataSource.getCachedDefinition(for: sanitizedWord) {
                return cachedDefinition
            }
            throw RepositoryError.unknownError(error)
        }
    }
    
    public func getCachedDefinition(for word: String) async throws -> WordDefinition? {
        let sanitizedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedWord.isEmpty else {
            throw RepositoryError.invalidInput("Word cannot be empty")
        }
        
        return try await localDataSource.getCachedDefinition(for: sanitizedWord)
    }
    
    public func cacheDefinition(_ definition: WordDefinition) async throws {
        try await localDataSource.cacheDefinition(definition)
    }
    
    public func getPastSearches() async throws -> [WordDefinition] {
        try await localDataSource.getPastSearches()
    }
}

/// Repository-specific errors that abstract away data layer implementation details
public enum RepositoryError: Error, Equatable {
    case invalidInput(String)
    case noDataFound
    case dataError(String)
    case networkError(Error)
    case serverError
    case unknownError(Error)
    
    public static func == (lhs: RepositoryError, rhs: RepositoryError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidInput(let lhsMsg), .invalidInput(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.noDataFound, .noDataFound):
            return true
        case (.dataError(let lhsMsg), .dataError(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.serverError, .serverError):
            return true
        case (.networkError, .networkError),
             (.unknownError, .unknownError):
            // For errors containing other errors, we can't easily compare them
            return true
        default:
            return false
        }
    }
}

extension RepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .noDataFound:
            return "No definition found for the requested word"
        case .dataError(let message):
            return "Data error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError:
            return "Server error occurred"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
