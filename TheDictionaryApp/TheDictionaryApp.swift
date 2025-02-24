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
    // Initialize the audio service at app level to maintain a single instance
    private let audioService: AudioService = AudioServiceImpl()
    
    var body: some Scene {
        WindowGroup {
            // Compose dependencies.
            let repository = WordDefinitionRepositoryImpl()
            let fetchWordDefinitionUseCase = DefaultFetchWordDefinitionUseCase(
                repository: repository
            )
            let pastSearchesUseCase = DefaultFetchPastSearchesUseCase(
                repository: repository
            )
            
            let viewModel = WordDefinitionViewModel(
                fetchDefinitionUseCase: fetchWordDefinitionUseCase,
                fetchPastSearchesUseCase: pastSearchesUseCase,
                audioService: audioService
            )
            WordSearchView(viewModel: viewModel)
        }
    }
}
