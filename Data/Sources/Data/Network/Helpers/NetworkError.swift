//
//  NetworkError.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

/// Represents possible network-related errors
public enum NetworkError: Error, Equatable, Sendable {
    /// The URL was invalid
    case invalidURL
    
    /// The request was invalid (e.g., empty word)
    case invalidRequest(String)
    
    /// The HTTP response was not valid
    case invalidResponse
    
    /// The requested resource was not found (404)
    case notFound
    
    /// There is no internet connection
    case noInternetConnection
    
    /// The request timed out
    case timeout
    
    /// The request was cancelled
    case cancelled
    
    /// Failed to decode the response data
    case decodingFailed(Error)
    
    /// Request failed with a specific status code (general case)
    case requestFailed(statusCode: Int, data: Data?)
    
    /// Client error (400-499)
    case clientError(statusCode: Int, data: Data?)
    
    /// Server error (500-599)
    case serverError(statusCode: Int, data: Data?)
    
    /// Unknown error
    case unknown(Error)
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidRequest(let lhsMsg), .invalidRequest(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.invalidResponse, .invalidResponse):
            return true
        case (.notFound, .notFound):
            return true
        case (.noInternetConnection, .noInternetConnection):
            return true
        case (.timeout, .timeout):
            return true
        case (.cancelled, .cancelled):
            return true
        case (.requestFailed(let lhsCode, _), .requestFailed(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.clientError(let lhsCode, _), .clientError(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.serverError(let lhsCode, _), .serverError(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.decodingFailed, .decodingFailed),
             (.unknown, .unknown):
            // For errors containing other errors, we can't easily compare them
            // Consider them equal if the type matches
            return true
        default:
            return false
        }
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .invalidResponse:
            return "The server returned an invalid response"
        case .notFound:
            return "The requested resource was not found"
        case .noInternetConnection:
            return "No internet connection available"
        case .timeout:
            return "The request timed out"
        case .cancelled:
            return "The request was cancelled"
        case .decodingFailed(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .requestFailed(let statusCode, _):
            return "Request failed with status code: \(statusCode)"
        case .clientError(let statusCode, _):
            return "Client error with status code: \(statusCode)"
        case .serverError(let statusCode, _):
            return "Server error with status code: \(statusCode)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
