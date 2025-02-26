//
//  PastSearchesManager.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Combine
import Domain

/// Manages past searches functionality
@MainActor
public class PastSearchesManager: PastSearchesManagerProtocol {
    // MARK: - Published Properties
    
    /// models of past searches for display
    @Published private(set) public var pastSearchDefinitions: [WordDefinition] = []
    
    // MARK: - Public Properties
    
    /// Publisher for past searchI models
    public var pastSearchDefinitionsPublisher: AnyPublisher<[WordDefinition], Never> {
        $pastSearchDefinitions.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    /// The use case for fetching past searches
    private let fetchPastSearchesUseCase: FetchPastSearchesUseCase
    
    /// Error handler for displaying errors
    private let errorHandler: ErrorHandlerProtocol
    
    // MARK: - Initialization
    
    public init(
        fetchPastSearchesUseCase: FetchPastSearchesUseCase,
        errorHandler: ErrorHandlerProtocol
    ) {
        self.fetchPastSearchesUseCase = fetchPastSearchesUseCase
        self.errorHandler = errorHandler
    }
    
    // MARK: - Public Methods
    
    public func loadPastSearches() async {
        do {
            let pastSearch = try await fetchPastSearchesUseCase.execute()
            pastSearchDefinitions = pastSearch
        } catch {
            errorHandler.showError("Unable to load past searches")
        }
    }
    
    /// Gets the most recent past search
    public func getMostRecentSearch() async -> WordDefinition? {
        do {
            return try await fetchPastSearchesUseCase.execute().first
        } catch {
            errorHandler.showError("Unable to retrieve most recent search")
            return nil
        }
    }
}
