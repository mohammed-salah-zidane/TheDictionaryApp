import Foundation
@testable import Domain

class MockWordDefinitionRepository: WordDefinitionRepository, @unchecked Sendable {
    // Track function calls
    var fetchDefinitionCalled = false
    var getCachedDefinitionCalled = false
    var cacheDefinitionCalled = false
    var getPastSearchesCalled = false
    
    // Configure return values
    var fetchDefinitionResult: Result<WordDefinition, Error> = .failure(NSError(domain: "", code: -1))
    var getCachedDefinitionResult: Result<WordDefinition?, Error> = .success(nil)
    var cacheDefinitionResult: Result<Void, Error> = .success(())
    var getPastSearchesResult: Result<[WordDefinition], Error> = .success([])
    
    func fetchDefinition(for word: String) async throws -> WordDefinition {
        fetchDefinitionCalled = true
        switch fetchDefinitionResult {
        case .success(let definition):
            return definition
        case .failure(let error):
            throw error
        }
    }
    
    func getCachedDefinition(for word: String) async throws -> WordDefinition? {
        getCachedDefinitionCalled = true
        switch getCachedDefinitionResult {
        case .success(let definition):
            return definition
        case .failure(let error):
            throw error
        }
    }
    
    func cacheDefinition(_ definition: WordDefinition) async throws {
        cacheDefinitionCalled = true
        switch cacheDefinitionResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func getPastSearches() async throws -> [WordDefinition] {
        getPastSearchesCalled = true
        switch getPastSearchesResult {
        case .success(let definitions):
            return definitions
        case .failure(let error):
            throw error
        }
    }
}
