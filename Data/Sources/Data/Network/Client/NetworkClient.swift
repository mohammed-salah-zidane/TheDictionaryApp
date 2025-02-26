//
//  NetworkClientProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

// MARK: - Network Client Protocol
public protocol NetworkClientProtocol: Sendable {
    /// Performs a network request and decodes the response
    /// - Parameter config: Configuration for the request
    /// - Returns: Decoded response of type T
    /// - Throws: NetworkError if the request fails
    func request<T: Decodable>(_ config: RequestConfigurable) async throws -> T
}

// MARK: - Network Client Implementation
public final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let logger: NetworkLoggerProtocol
    
    public init(
        configuration: URLSessionConfiguration = .default,
        logger: NetworkLoggerProtocol = NetworkLogger()
    ) {
        configuration.timeoutIntervalForRequest = NetworkConfig.timeout
        configuration.timeoutIntervalForResource = NetworkConfig.timeout
        self.session = URLSession(configuration: configuration)
        self.logger = logger
    }
    
    public func request<T: Decodable>(_ config: RequestConfigurable) async throws -> T {
        guard let url = URL(string: config.url) else {
            logger.logError(NetworkError.invalidURL)
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = config.method.rawValue
        request.allHTTPHeaderFields = config.headers
        request.httpBody = config.bodyData
        
        // Add a unique request ID for tracking purposes
        let requestId = UUID().uuidString
        request.addValue(requestId, forHTTPHeaderField: "X-Request-ID")
        
        logger.logRequest(request)
        
        do {
            let (data, response) = try await session.data(for: request)
            logger.logResponse(response, data: data, error: nil)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                // Map status codes to specific error cases
                switch httpResponse.statusCode {
                case 404:
                    throw NetworkError.notFound
                case 400...499:
                    throw NetworkError.clientError(statusCode: httpResponse.statusCode, data: data)
                case 500...599:
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
                default:
                    throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, data: data)
                }
            }
            
            let jsonDecoder = config.decoder ?? JSONDecoder()
            do {
                return try jsonDecoder.decode(T.self, from: data)
            } catch {
                logger.logError(NetworkError.decodingFailed(error))
                throw NetworkError.decodingFailed(error)
            }
        } catch let urlError as URLError {
            switch urlError.code {
            case .cancelled:
                throw NetworkError.cancelled
            case .timedOut:
                throw NetworkError.timeout
            case .notConnectedToInternet:
                throw NetworkError.noInternetConnection
            default:
                throw NetworkError.unknown(urlError)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            logger.logError(error)
            throw NetworkError.unknown(error)
        }
    }
}
