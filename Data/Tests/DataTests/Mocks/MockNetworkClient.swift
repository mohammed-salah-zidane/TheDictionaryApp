//
//  MockNetworkClient.swift
//  Data
//
//  Created by Mohamed Salah on 27/02/2025.
//


import XCTest
import CoreData
@testable import Data
@testable import Domain

// MARK: - MockNetworkClient

/// A mock network client that returns a predetermined result.
final class MockNetworkClient: NetworkClientProtocol, @unchecked Sendable {
    var result: Result<[WordDefinitionDTO], Error>?
    
    func request<T: Decodable>(_ config: RequestConfigurable) async throws -> T {
        guard let result = result else {
            throw NetworkError.unknown(NSError(domain: "", code: 0))
        }
        switch result {
        case .success(let dtos):
            // Attempt to cast the DTOs to the requested generic type T
            if let dtosT = dtos as? T {
                return dtosT
            } else {
                throw NetworkError.decodingFailed(NSError(domain: "", code: 0))
            }
        case .failure(let error):
            throw error
        }
    }
}
