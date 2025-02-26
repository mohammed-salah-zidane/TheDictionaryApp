//
//  MockRemoteDataSource.swift
//  DataTests
//
//  Created by Mohamed Salah on 27/02/2025.
//

import Foundation
@testable import Data
@testable import Domain

final class MockRemoteDataSource: RemoteDataSourceProtocol, @unchecked Sendable {
    var result: Result<[WordDefinition], Error>?
    
    func fetchDefinition(for word: String) async throws -> [WordDefinition] {
        guard let result = result else {
            throw NetworkError.unknown(NSError(domain: "MockError", code: 0))
        }
        switch result {
        case .success(let definitions):
            return definitions
        case .failure(let error):
            throw error
        }
    }
}

