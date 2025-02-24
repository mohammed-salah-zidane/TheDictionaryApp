//
//  CoreDataStack.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import CoreData

public class CoreDataStack {
    public static let shared = CoreDataStack()
    
    public let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "WordDefinitionModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading CoreData store: \(error)")
            }
        }
    }
    
    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func saveContext() async throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}
