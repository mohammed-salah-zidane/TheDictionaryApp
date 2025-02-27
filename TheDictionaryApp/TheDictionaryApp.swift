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
            WordSearchView(viewModel: dependencyManager.makeWordDefinitionViewModel())
        }
    }
}
