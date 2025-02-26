//
//  TheDictionaryAppApp.swift
//  TheDictionaryApp
//
//  Created by Mohamed Salah on 24/02/2025.
//

import SwiftUI
import Domain
import Data
import WordFeature

@main
struct TheDictionaryApp: App {
    // Use the dependency injection manager to access services
    private let dependencyManager = DependencyInjectionManager.shared
    
    var body: some Scene {
        WindowGroup {
            // Use the factory method to create the ViewModel with all required dependencies
            WordSearchView(viewModel: dependencyManager.makeWordDefinitionViewModel())
        }
    }
}
