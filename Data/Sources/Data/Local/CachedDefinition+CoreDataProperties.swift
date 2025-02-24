//
//  func.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//


import Foundation
import CoreData

extension CachedDefinition {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedDefinition> {
        return NSFetchRequest<CachedDefinition>(entityName: "CachedDefinition")
    }
    
    @NSManaged public var word: String
    @NSManaged public var jsonData: Data
    @NSManaged public var timestamp: Date
}

extension CachedDefinition : Identifiable {
}
