//
//  MockURLProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 27/02/2025.
//


import XCTest
import CoreData
@testable import Data
@testable import Domain

// MARK: - MockURLProtocol

/// A custom URLProtocol subclass to intercept and simulate URLSession responses.
final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    // Define a Sendable handler type
    struct RequestHandler: @unchecked Sendable {
        let handle: (URLRequest) throws -> (HTTPURLResponse, Data?)
    }
    
    private actor RequestHandlerStore {
        var handler: RequestHandler?
        
        init(handler: RequestHandler? = nil) {
            self.handler = handler
        }
        
        func getHandler() -> RequestHandler? {
            handler
        }
        
        func setHandler(_ newHandler: RequestHandler?) {
            handler = newHandler
        }
    }
    
    private static let store = RequestHandlerStore()
    
    static func getRequestHandler() async -> RequestHandler? {
        await store.getHandler()
    }
    
    static func setRequestHandler(_ handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data?)) async {
        await store.setHandler(RequestHandler(handle: handler))
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        Task {
            guard let handler = await Self.getRequestHandler() else {
                fatalError("No request handler set")
            }
            
            do {
                let (response, data) = try handler.handle(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }
    
    override func stopLoading() {
        // No cleanup needed.
    }
}