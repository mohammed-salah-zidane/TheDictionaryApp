//
//  PastSearchesManagerProtocol.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Combine
import Domain

/// Protocol defining past searches management functionality
@MainActor public protocol PastSearchesManagerProtocol: AnyObject, Sendable {
    /// Publisher for UI models of past searches
    var pastSearchDefinitionsPublisher: AnyPublisher<[WordDefinition], Never> {
        get
    }
    
    var pastSearchDefinitions: [WordDefinition] { get }

    /// Loads past searches from the repository
    func loadPastSearches() async
    
    /// Gets the most recent past search
    func getMostRecentSearch() async -> WordDefinition?
}
