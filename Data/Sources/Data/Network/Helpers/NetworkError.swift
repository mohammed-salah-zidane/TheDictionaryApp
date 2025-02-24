//
//  NetworkError.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

public enum NetworkError: LocalizedError, Sendable {
    
    case invalidURL
    case requestFailed(statusCode: Int, data: Data?)
    case invalidResponse
    case decodingFailed(Error)
    case cancelled
    case timeout
    case noInternetConnection
    case unknown(Error)
    case notFound
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .requestFailed(let statusCode, _):
            return "Request failed with status code: \(statusCode)"
        case .invalidResponse:
            return "Received invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .cancelled:
            return "Request was cancelled"
        case .timeout:
            return "Request timed out"
        case .noInternetConnection:
            return "No internet connection available"
        case .notFound:
            return "Resource not found"
        case .unknown(let error):
            return "Unknown error occurred: \(error.localizedDescription)"
        }
    }
}
