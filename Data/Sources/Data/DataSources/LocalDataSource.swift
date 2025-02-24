//
//  LocalDataSourceProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import CoreData
import Domain

public protocol LocalDataSourceProtocol {
    func getCachedDefinition(for word: String) async throws -> WordDefinition?
    func cacheDefinition(_ definition: WordDefinition) async throws
    func getPastSearches() async throws -> [WordDefinition]
}

public class LocalDataSource: LocalDataSourceProtocol {
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
        if let cached = results.first {
            let definition = try JSONDecoder().decode(WordDefinition.self, from: cached.jsonData)
            return definition
        }
        return nil
    }
    
    public func cacheDefinition(_ definition: WordDefinition) async throws {
        let context = coreDataStack.context
        let cached = CachedDefinition(context: context)
        cached.word = definition.word
        cached.jsonData = try JSONEncoder().encode(definition)
        cached.timestamp = Date()
        try await coreDataStack.saveContext()
    }
    
    public func getPastSearches() async throws -> [WordDefinition] {
        let context = coreDataStack.context
        let fetchRequest: NSFetchRequest<CachedDefinition> = CachedDefinition.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let results = try context.fetch(fetchRequest)
        let definitions = try results.map { try JSONDecoder().decode(WordDefinition.self, from: $0.jsonData) }
        return definitions
    }
}
