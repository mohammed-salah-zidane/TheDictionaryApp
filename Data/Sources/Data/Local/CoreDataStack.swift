//
//  CoreDataStack.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import CoreData

import Foundation
import CoreData

public class CoreDataStack {
    public static let shared = CoreDataStack()
    
    public let persistentContainer: NSPersistentContainer
    
    private init() {
        // 1) Try to find the compiled model (mom or momd) in SPM’s resource bundle
        guard let modelURL = Bundle.module.url(forResource: "WordDefinitionModel", withExtension: "momd")
                ?? Bundle.module.url(forResource: "WordDefinitionModel", withExtension: "mom") else {
            fatalError("Could not find WordDefinitionModel.momd or WordDefinitionModel.mom in SPM bundle.")
        }
        
        // 2) Create an NSManagedObjectModel from that URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create NSManagedObjectModel from \(modelURL).")
        }
        
        // 3) Pass the model into the NSPersistentContainer
        persistentContainer = NSPersistentContainer(name: "WordDefinitionModel", managedObjectModel: model)
        
        // 4) Load the persistent store
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading Core Data store: \(error)")
            }
        }
    }
    
    public var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    public func saveContext() async throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}

extension CoreDataStack: @unchecked Sendable {}
