//
//  MoyaProvider+Async.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import Moya

public extension MoyaProvider {
    func requestAsync(_ target: Target) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
