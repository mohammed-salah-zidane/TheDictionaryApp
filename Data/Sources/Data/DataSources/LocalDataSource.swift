//
//  LocalDataSourceProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import CoreData
import Domain

/// Protocol defining operations for local storage of word definitions
public protocol LocalDataSourceProtocol: Sendable {
    /// Retrieves a cached definition for the specified word if available
    /// - Parameter word: The word to look up
    /// - Returns: A WordDefinition if found, nil otherwise
    func getCachedDefinition(for word: String) async throws -> WordDefinition?
    
    /// Caches a word definition for future retrieval
    /// - Parameter definition: The WordDefinition to cache
    func cacheDefinition(_ definition: WordDefinition) async throws
    
    /// Retrieves all previously cached word definitions
    /// - Returns: An array of WordDefinition objects, sorted by most recent first
    func getPastSearches() async throws -> [WordDefinition]
}

public final class LocalDataSource: LocalDataSourceProtocol {
    private let coreDataStack: CoreDataStack
    
    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    public func getCachedDefinition(for word: String) async throws -> WordDefinition? {
        // Perform all Core Data operations on the main context
        return try await coreDataStack.context.perform {
            let fetchRequest: NSFetchRequest<CachedDefinition> = CachedDefinition.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word ==[c] %@", word)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            let results = try self.coreDataStack.context.fetch(fetchRequest)
            guard let cached = results.first,
                  let data = cached.jsonData else { return nil }
            return try JSONDecoder().decode(WordDefinition.self, from: data)
        }
    }
    
    public func cacheDefinition(_ definition: WordDefinition) async throws {
        // Perform all Core Data operations on the main context
        try await coreDataStack.context.perform {
            let fetchRequest: NSFetchRequest<CachedDefinition> = CachedDefinition.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word ==[c] %@", definition.word)
            
            // Safely handle existing entries
            let existingEntries = try self.coreDataStack.context.fetch(fetchRequest)
            
            let cachedDefinition: CachedDefinition
            
            if let existingEntry = existingEntries.first {
                // Update existing entry
                cachedDefinition = existingEntry
                
                // Safely delete duplicates
                if existingEntries.count > 1 {
                    // Use enumerated to avoid potential array access issues
                    for (index, entry) in existingEntries.enumerated() {
                        if index > 0 { // Skip the first one
                            self.coreDataStack.context.delete(entry)
                        }
                    }
                }
            } else {
                // Create new entry
                cachedDefinition = CachedDefinition(context: self.coreDataStack.context)
                cachedDefinition.word = definition.word
            }
            
            // Update the cached definition
            cachedDefinition.jsonData = try JSONEncoder().encode(definition)
            cachedDefinition.timestamp = Date()
            
            // Save context
            if self.coreDataStack.context.hasChanges {
                try self.coreDataStack.context.save()
            }
        }
    }
    
    public func getPastSearches() async throws -> [WordDefinition] {
        // Perform all Core Data operations on the main context
        return try await coreDataStack.context.perform {
            let fetchRequest: NSFetchRequest<CachedDefinition> = CachedDefinition.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "jsonData != nil")
            
            let results = try self.coreDataStack.context.fetch(fetchRequest)
            
            return try results.compactMap { cached -> WordDefinition? in
                guard let data = cached.jsonData else { return nil }
                return try JSONDecoder().decode(WordDefinition.self, from: data)
            }
        }
    }
}
