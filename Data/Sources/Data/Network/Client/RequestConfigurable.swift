//
//  HTTPMethod.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Request Configuration Protocol
public protocol RequestConfigurable: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: Any]? { get }
    var bodyParameters: [String: Any]? { get }
    var decoder: JSONDecoder? { get }
}

public extension RequestConfigurable {
    var headers: [String: String]? { nil }
    var queryParameters: [String: Any]? { nil }
    var bodyParameters: [String: Any]? { nil }
    var decoder: JSONDecoder? { nil }
    
    var url: String {
        let urlString = baseURL + path
        guard let queryParameters = queryParameters,
              !queryParameters.isEmpty,
              var components = URLComponents(string: urlString) else {
            return urlString
        }
        
        components.queryItems = queryParameters.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        
        return components.url?.absoluteString ?? urlString
    }
    
    var bodyData: Data? {
        guard let bodyParameters = bodyParameters else { return nil }
        return try? JSONSerialization.data(withJSONObject: bodyParameters)
    }
}
