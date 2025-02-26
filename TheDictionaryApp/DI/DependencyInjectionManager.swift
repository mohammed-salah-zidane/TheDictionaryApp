//
//  DependencyInjectionManager.swift
//  TheDictionaryApp
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Data
import Domain
import WordFeature

/// A service locator that manages dependencies across the application.
/// This class follows the singleton pattern to ensure consistent access to dependencies.
@MainActor final class DependencyInjectionManager {
    static let shared = DependencyInjectionManager()
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    // MARK: - Services
    
    /// Provides a shared instance of the AudioService.
    lazy var audioService: AudioService = {
        return AudioServiceImpl()
    }()

    
    // MARK: - Managers
    
    /// Provides a network state manager for handling connectivity status.
    lazy var networkStateManager: NetworkStateManagerProtocol = {
        return NetworkStateManager(networkMonitor: NetworkMonitor.shared)
    }()
    
    /// Provides an audio playback manager for handling audio playback.
    lazy var audioPlaybackManager: AudioPlaybackManagerProtocol = {
        return AudioPlaybackManager(audioService: audioService)
    }()
    
    lazy var errorHandler: ErrorHandlerProtocol = {
        return ErrorHandler()
    }()
    
    lazy var pastSearchesManager: PastSearchesManagerProtocol = {
        return PastSearchesManager(
            fetchPastSearchesUseCase: fetchPastSearchesUseCase,
            errorHandler: errorHandler
        )
    }()
    
    // MARK: - Repository
    
    /// Provides a repository for word definitions.
    lazy var wordDefinitionRepository: WordDefinitionRepository = {
        return WordDefinitionRepositoryImpl()
    }()
    
    // MARK: - Use Cases
    
    lazy var fetchWordDefinitionUseCase: FetchWordDefinitionUseCase = {
        return DefaultFetchWordDefinitionUseCase(repository: wordDefinitionRepository)
    }()
    
    lazy var fetchPastSearchesUseCase: FetchPastSearchesUseCase = {
        return DefaultFetchPastSearchesUseCase(repository: wordDefinitionRepository)
    }()
    
    // MARK: - ViewModels
    
    @MainActor func makeWordDefinitionViewModel() -> WordDefinitionViewModel {
        return WordDefinitionViewModel(
            fetchDefinitionUseCase: fetchWordDefinitionUseCase,
            networkStateManager: networkStateManager,
            audioPlaybackManager: audioPlaybackManager,
            pastSearchesManager: pastSearchesManager,
            errorHandler: errorHandler
        )
    }
}
