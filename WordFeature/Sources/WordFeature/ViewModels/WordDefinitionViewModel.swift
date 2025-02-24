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
    
    private let fetchDefinitionUseCase: FetchWordDefinitionUseCase
    private let repository: WordDefinitionRepository
    
    public init(fetchDefinitionUseCase: FetchWordDefinitionUseCase,
                repository: WordDefinitionRepository) {
        self.fetchDefinitionUseCase = fetchDefinitionUseCase
        self.repository = repository
    }
    
    public func search() async {
        guard !word.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Enter a valid word."
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            let result = try await fetchDefinitionUseCase.execute(for: word)
            definition = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func loadPastSearches() async {
        do {
            pastSearches = try await repository.getPastSearches()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
