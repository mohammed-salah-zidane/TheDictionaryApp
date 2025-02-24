import Foundation

public protocol FetchPastSearchesUseCase: Sendable {
    func execute() async throws -> [WordDefinition]
}

public final class DefaultFetchPastSearchesUseCase: FetchPastSearchesUseCase {
    private let repository: WordDefinitionRepository
    
    public init(repository: WordDefinitionRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> [WordDefinition] {
        return try await repository.getPastSearches()
    }
}
