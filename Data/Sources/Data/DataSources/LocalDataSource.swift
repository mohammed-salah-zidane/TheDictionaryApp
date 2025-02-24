//
//  LocalDataSourceProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import CoreData
import Domain

public protocol LocalDataSourceProtocol: Sendable {
    func getCachedDefinition(for word: String) async throws -> WordDefinition?
    func cacheDefinition(_ definition: WordDefinition) async throws
    func getPastSearches() async throws -> [WordDefinition]
}

public final class LocalDataSource: LocalDataSourceProtocol {
    private let coreDataStack: CoreDataStack
    
    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    public func getCachedDefinition(for word: String) async throws -> WordDefinition? {
        let context = coreDataStack.context
        let fetchRequest: NSFetchRequest<CachedDefinition> = CachedDefinition.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word ==[c] %@", word)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let results = try context.fetch(fetchRequest)
        if let cached = results.first,
           let data = cached.jsonData {
            return try JSONDecoder().decode(WordDefinition.self, from: data)
        }
        return nil
    }
    
    public func cacheDefinition(_ definition: WordDefinition) async throws {
        let context = coreDataStack.context
        
        // First, fetch any existing entries for this word
        let fetchRequest: NSFetchRequest<CachedDefinition> = CachedDefinition.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word ==[c] %@", definition.word)
        let existingEntries = try context.fetch(fetchRequest)
        
        let cachedDefinition: CachedDefinition
        
        if let existingEntry = existingEntries.first {
            // Update existing entry
            cachedDefinition = existingEntry
            
            // Delete any additional duplicate entries if they exist
            if existingEntries.count > 1 {
                existingEntries.dropFirst().forEach(context.delete)
            }
        } else {
            // Create new entry if none exists
            cachedDefinition = CachedDefinition(context: context)
            cachedDefinition.word = definition.word
        }
        
        // Update the cached definition
        cachedDefinition.jsonData = try JSONEncoder().encode(definition)
        cachedDefinition.timestamp = Date()
        
        try await coreDataStack.saveContext()
    }
    
    public func getPastSearches() async throws -> [WordDefinition] {
        let context = coreDataStack.context
        let fetchRequest: NSFetchRequest<CachedDefinition> = CachedDefinition.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        // Add predicate to ensure we only get entries with valid data
        fetchRequest.predicate = NSPredicate(format: "jsonData != nil")
        
        let results = try context.fetch(fetchRequest)
        
        return try results.compactMap { cached -> WordDefinition? in
            guard let data = cached.jsonData else { return nil }
            return try JSONDecoder().decode(WordDefinition.self, from: data)
        }
    }
}
