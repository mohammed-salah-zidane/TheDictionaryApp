//
//  WordDefinitionViewModel.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Domain
import SwiftUI

@MainActor
public class WordDefinitionViewModel: ObservableObject {
    @Published public var word: String = ""
    @Published public var definition: WordDefinition?
    @Published public var pastSearches: [WordDefinition] = []
    @Published public var errorMessage: String?
    @Published public var isLoading: Bool = false
    @Published public var showErrorAlert: Bool = false
    @Published public var selectedDetailDefinition: WordDefinition?
    @Published public var showDetailView: Bool = false
    @Published public var selectedPastSearch: WordDefinition?
    @Published public var showPastSearchDetail: Bool = false
    @Published public var showPastSearches: Bool = false
    @Published public var isAudioPlaying: Bool = false
    
    private let fetchDefinitionUseCase: FetchWordDefinitionUseCase
    private let fetchPastSearchesUseCase: FetchPastSearchesUseCase
    private let audioService: AudioService
    private var currentAudioURL: String?
    
    public init(fetchDefinitionUseCase: FetchWordDefinitionUseCase,
                fetchPastSearchesUseCase: FetchPastSearchesUseCase,
                audioService: AudioService) {
        self.fetchDefinitionUseCase = fetchDefinitionUseCase
        self.fetchPastSearchesUseCase = fetchPastSearchesUseCase
        self.audioService = audioService
        
        // Load past searches when initializing
        Task {
            await loadPastSearches()
        }
    }
    
    public func search() async {
        guard !word.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Please enter a word to search")
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            let result = try await fetchDefinitionUseCase.execute(for: word)
            definition = result
            // After successful search, reload past searches
            await loadPastSearches()
        } catch {
            showError(friendlyErrorMessage(for: error))
        }
        isLoading = false
    }
    
    public func loadPastSearches() async {
        do {
            pastSearches = try await fetchPastSearchesUseCase.execute()
        } catch {
            showError("Unable to load past searches")
        }
    }
    
    public func selectPastSearch(_ definition: WordDefinition) {
        self.word = definition.word
        Task {
            await search()
        }
    }
    
    public func showDefinitionDetail(_ definition: WordDefinition) {
        self.selectedDetailDefinition = definition
        self.showDetailView = true
    }
    
    public func showPastSearchDetails(_ definition: WordDefinition) {
        selectedPastSearch = definition
        showPastSearchDetail = true
    }
    
    public func playAudio(from url: String) {
        if isAudioPlaying && currentAudioURL == url {
            stopAudio()
        } else {
            currentAudioURL = url
            isAudioPlaying = true
            audioService.play(from: url)
        }
    }
    
    public func stopAudio() {
        isAudioPlaying = false
        currentAudioURL = nil
        audioService.stop()
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    private func friendlyErrorMessage(for error: Error) -> String {
        // Convert technical errors to user-friendly messages
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet:
                return "Please check your internet connection and try again"
            case .serverError:
                return "Unable to reach the dictionary server. Please try again later"
            default:
                return "An unexpected error occurred. Please try again"
            }
        }
        return "Unable to find the word. Please check your spelling and try again"
    }
}

enum NetworkError: Error {
    case noInternet
    case serverError
    case invalidResponse
}
