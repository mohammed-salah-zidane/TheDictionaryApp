//
//  DomainError.swift
//  Domain
//
//  Created by Mohamed Salah on 25/02/2025.
//

import Foundation

/// Represents domain-specific errors that can occur during business operations.
/// These errors are independent of the underlying infrastructure or data source.
public enum DomainError: Error, Equatable {
    /// Input validation failed
    case invalidInput(String)
    
    /// No data was found for the requested resource
    case notFound
    
    /// Network operations failed
    case networkFailure
    
    /// Server-side error occurred
    case serverError
    
    /// Error occurred during data processing
    case dataProcessingError(String)
    
    /// An unexpected error occurred
    case unexpectedError
    
    public static func == (lhs: DomainError, rhs: DomainError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidInput(let lhsMsg), .invalidInput(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.notFound, .notFound):
            return true
        case (.networkFailure, .networkFailure):
            return true
        case (.serverError, .serverError):
            return true
        case (.dataProcessingError(let lhsMsg), .dataProcessingError(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.unexpectedError, .unexpectedError):
            return true
        default:
            return false
        }
    }
}

extension DomainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .notFound:
            return "The requested information was not found"
        case .networkFailure:
            return "Network operation failed"
        case .serverError:
            return "A server error occurred"
        case .dataProcessingError(let message):
            return "Data processing error: \(message)"
        case .unexpectedError:
            return "An unexpected error occurred"
        }
    }
}
