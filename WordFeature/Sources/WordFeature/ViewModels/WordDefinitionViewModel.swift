//
//  WordDefinitionViewModel.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Domain
import SwiftUI
import Data

@MainActor
public class WordDefinitionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var word: String = "" {
        didSet {
            // Reset definition when text field is empty
            if word.isEmpty {
                definition = nil
            }
        }
    }
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
    @Published public var isOnline: Bool = true
    @Published public var isInitialLoad: Bool = true
    @Published public var showNetworkStatus: Bool = false
    
    private var isFromPastSearch = false
    private let fetchDefinitionUseCase: FetchWordDefinitionUseCase
    private let fetchPastSearchesUseCase: FetchPastSearchesUseCase
    private let audioService: AudioService
    private let networkMonitor: NetworkMonitorProtocol
    private var currentAudioURL: String?
    private var wasOffline: Bool = false
    
    public init(fetchDefinitionUseCase: FetchWordDefinitionUseCase,
                fetchPastSearchesUseCase: FetchPastSearchesUseCase,
                audioService: AudioService,
                networkMonitor: NetworkMonitorProtocol) {
        self.fetchDefinitionUseCase = fetchDefinitionUseCase
        self.fetchPastSearchesUseCase = fetchPastSearchesUseCase
        self.audioService = audioService
        self.networkMonitor = networkMonitor
        
        // Start monitoring network and load initial data
        Task {
            await setupNetworkMonitoring()
            await loadInitialData()
        }
    }
    
    private func setupNetworkMonitoring() async {
        isOnline = networkMonitor.isConnected
        
        // Show past searches by default when offline
        if !isOnline && isInitialLoad {
            showPastSearches = true
            isInitialLoad = false
        }
        
        // Start a Task to monitor network changes
        Task {
            while true {
                let connected = await networkMonitor.waitForConnection(timeout: 1.0)
                await MainActor.run {
                    if self.isOnline != connected {
                        self.isOnline = connected
                        handleNetworkStatusChange()
                    }
                }
            }
        }
    }
    
    private func loadInitialData() async {
        await loadPastSearches()
        
        // If offline and we have past searches, show the most recent one
        if !isOnline && !pastSearches.isEmpty {
            definition = pastSearches.first
        }
    }
    
    private func handleNetworkStatusChange() {
        if isOnline {
            // Only show online status if we were previously offline
            if wasOffline {
                showNetworkStatus = true
                // Start a task to auto-dismiss the status
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 3_000_000_000)  // 3 seconds
                    if !Task.isCancelled {
                        showNetworkStatus = false
                    }
                }
            }
            
            // If we're back online and have a word to search, retry the search
            if !word.isEmpty {
                Task {
                    await search()
                }
            }
            
            // Hide past searches if they were shown due to being offline
            if showPastSearches && isInitialLoad {
                showPastSearches = false
                isInitialLoad = false
            }
            
            wasOffline = false
        } else {
            // Show past searches when going offline
            showPastSearches = true
            wasOffline = true
            showNetworkStatus = false  // Hide online status if it was showing
        }
    }
    
    public func search() async {
        let trimmedWord = word.trimmingCharacters(in: .whitespaces)
        guard !trimmedWord.isEmpty else {
            definition = nil
            return
        }
        
        guard trimmedWord.rangeOfCharacter(from: .letters) != nil else {
            showError("Please enter a valid word")
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            let result = try await fetchDefinitionUseCase.execute(for: trimmedWord)
            definition = result
            await loadPastSearches()
            if !isInitialLoad {
                showPastSearches = false
            }
        } catch let error as NetworkError {
            switch error {
            case .noInternet:
                // Show error but don't show past searches if coming from past search selection
                showError("No internet connection. Showing cached results.")
                if !isFromPastSearch {
                    showPastSearches = true
                }
            case .invalidResponse:
                showError("Word not found")
                if !isFromPastSearch {
                    showPastSearches = true
                }
            default:
                showError(error.localizedDescription)
                if !isFromPastSearch {
                    showPastSearches = true
                }
            }
        } catch {
            showError(error.localizedDescription)
            if !isFromPastSearch {
                showPastSearches = true
            }
        }
        isLoading = false
        isFromPastSearch = false  // Reset the flag after search completes
    }
    
    
    public func loadPastSearches() async {
        do {
            pastSearches = try await fetchPastSearchesUseCase.execute()
        } catch {
            showError("Unable to load past searches")
        }
    }
    
    public func selectPastSearch(_ definition: WordDefinition) {
        showPastSearches = false
        self.word = definition.word
        isFromPastSearch = true  // Set flag before searching
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
    
    public func dismissNetworkStatus() {
        showNetworkStatus = false
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}

enum NetworkError: Error {
    case noInternet
    case serverError
    case invalidResponse
}
