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
import Combine

/// Manages the word definition state and coordinates between different services
@MainActor
public class WordDefinitionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var word: String = "" {
        didSet {
            if word.isEmpty {
                definition = nil
            }
        }
    }
    @Published public var definition: WordDefinition?
    @Published public var isLoading: Bool = false
    @Published public var showDetailView: Bool = false
    @Published public var showPastSearches: Bool = false
    @Published public var isInitialLoad: Bool = true
    @Published public var isAudioPlaying: Bool = false
    @Published private(set) public var selectedDetailDefinition: WordDefinition?

    // MARK: - Dependencies
    private let fetchDefinitionUseCase: FetchWordDefinitionUseCase
    private let networkStateManager: NetworkStateManagerProtocol
    private let audioPlaybackManager: AudioPlaybackManagerProtocol
    private let pastSearchesManager: PastSearchesManagerProtocol
    private let errorHandler: ErrorHandlerProtocol

    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var isFromPastSearch = false

    // MARK: - Publishers
    public var isOnlinePublisher: AnyPublisher<Bool, Never> {
        networkStateManager.isOnlinePublisher
    }

    public var pastSearchesPublisher: AnyPublisher<[WordDefinition], Never> {
        pastSearchesManager.pastSearchDefinitionsPublisher
    }

    public var errorMessagePublisher: AnyPublisher<String?, Never> {
        errorHandler.errorMessagePublisher
    }

    public var showErrorAlertPublisher: AnyPublisher<Bool, Never> {
        errorHandler.showErrorAlertPublisher
    }

    // MARK: - Computed Properties
    public var pastSearches: [WordDefinition] {
        pastSearchesManager.pastSearchDefinitions
    }

    public var isOnline: Bool {
        networkStateManager.isOnline
    }

    public var showErrorAlert: Bool {
        get { errorHandler.showErrorAlert }
        set { if !newValue { errorHandler.resetError() } }
    }

    public var errorMessage: String? {
        errorHandler.errorMessage
    }

    // MARK: - Initialization
    public init(
        fetchDefinitionUseCase: FetchWordDefinitionUseCase,
        networkStateManager: NetworkStateManagerProtocol,
        audioPlaybackManager: AudioPlaybackManagerProtocol,
        pastSearchesManager: PastSearchesManagerProtocol,
        errorHandler: ErrorHandlerProtocol
    ) {
        self.fetchDefinitionUseCase = fetchDefinitionUseCase
        self.networkStateManager = networkStateManager
        self.audioPlaybackManager = audioPlaybackManager
        self.pastSearchesManager = pastSearchesManager
        self.errorHandler = errorHandler

        setupSubscriptions()

        Task {
            await loadInitialData()
        }
    }

    deinit {
        searchTask?.cancel()
    }

    private func setupSubscriptions() {
        // Observe network state changes
        networkStateManager.isOnlinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOnline in
                guard let self = self else { return }
                self.handleNetworkStateChange(isOnline: isOnline)
            }
            .store(in: &cancellables)

        // Observe past searches changes
        pastSearchesManager.pastSearchDefinitionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Observe audio playback state
        audioPlaybackManager.isPlayingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.isAudioPlaying = isPlaying
            }
            .store(in: &cancellables)
    }

    private func loadInitialData() async {
        await pastSearchesManager.loadPastSearches()

        if !isOnline, let recentSearch = await pastSearchesManager.getMostRecentSearch() {
            definition = recentSearch
            showPastSearches = true
        }

        isInitialLoad = false
    }

    // MARK: - Public Methods
    public func search() async {
        // Cancel any existing search task
        searchTask?.cancel()

        let trimmedWord = word.trimmingCharacters(in: .whitespaces)
        guard validateSearchInput(trimmedWord) else { return }

        isLoading = true

        // Create a new search task
        searchTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                let result = try await fetchDefinitionUseCase.execute(for: trimmedWord)

                // Check if the task was cancelled
                if Task.isCancelled { return }

                await MainActor.run {
                    self.definition = result
                    if !self.isInitialLoad {
                        self.showPastSearches = false
                    }
                }

                await self.pastSearchesManager.loadPastSearches()
            } catch {
                if !Task.isCancelled {
                    self.errorHandler.handleRepositoryError(error, for: trimmedWord)
                    if !self.isFromPastSearch {
                        self.showPastSearches = true
                    }
                }
            }

            await MainActor.run {
                self.isLoading = false
                self.isFromPastSearch = false
            }
        }
    }

    public func selectPastSearch(_ definition: WordDefinition) {
        self.word = definition.word
        isFromPastSearch = true
        
        // If we're online, fetch fresh data
        if isOnline {
            Task {
                await search()
            }
        } else {
            // If offline, use the cached definition
            self.definition = definition
        }
        showPastSearches = false
    }

    public func showDefinitionDetail(_ definition: WordDefinition) {
        selectedDetailDefinition = definition
    }

    public func dismissDetailView() {
        selectedDetailDefinition = nil
    }

    public func playAudio(from url: String) {
        guard isOnline else {
            errorHandler.showError("Cannot play audio while offline")
            return
        }
        audioPlaybackManager.playAudio(from: url)
    }

    public func stopAudio() {
        audioPlaybackManager.stopAudio()
    }

    // MARK: - Private Methods
    private func validateSearchInput(_ word: String) -> Bool {
        guard !word.isEmpty else {
            definition = nil
            errorHandler.showError("Please enter a valid word")
            return false
        }

        guard word.rangeOfCharacter(from: .letters) != nil else {
            errorHandler.showError("Please enter a valid word")
            return false
        }

        return true
    }

    private func handleNetworkStateChange(isOnline: Bool) {
        if isOnline {
            errorHandler.resetError()
            if !word.isEmpty {
                Task { await search() }
            }
        } else {
            showPastSearches = true
        }
    }
}
