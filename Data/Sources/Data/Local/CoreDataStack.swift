//
//  CoreDataStack.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import CoreData

/// A simple CoreDataStack with a public initializer, so it can be subclassed for tests.
public class CoreDataStack {
    public let persistentContainer: NSPersistentContainer
    private var isStoreLoaded = false
    
    /// Designated initializer. You can optionally pass `inMemory: true` for testing.
    public init(modelName: String = "WordDefinitionModel", inMemory: Bool = false) {
        // 1) Locate the compiled model (momd or mom)
        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd")
            ?? Bundle.module.url(forResource: modelName, withExtension: "mom") else {
            fatalError("Could not find \(modelName).momd or \(modelName).mom in SPM bundle.")
        }
        
        // 2) Create NSManagedObjectModel
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create NSManagedObjectModel from \(modelURL).")
        }
        
        // 3) Create NSPersistentContainer
        persistentContainer = NSPersistentContainer(name: modelName, managedObjectModel: model)
        
        // 4) If in-memory, adjust the store description
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }
        
        // 5) Load stores immediately after initialization
        persistentContainer.loadPersistentStores { [weak self] _, error in
            if let error = error {
                fatalError("Error loading Core Data store: \(error)")
            }
            self?.isStoreLoaded = true
        }
    }
    
    /// Access the main NSManagedObjectContext
    public var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    /// Saves the main context if it has changes.
    public func saveContext() async throws {
        guard isStoreLoaded else {
            throw CoreDataError.storeNotLoaded
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
}

/// Add CoreDataError enum
public enum CoreDataError: Error {
    case storeNotLoaded
}

// Mark the core data stack itself as @unchecked Sendable if needed
extension CoreDataStack: @unchecked Sendable {}
