//
//  WordSearchView.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import SwiftUI
import Domain

public struct WordSearchView: View {
    @StateObject var viewModel: WordDefinitionViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    public init(viewModel: WordDefinitionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    // Network Status Bar
                    if !viewModel.isOnline || viewModel.showNetworkStatus {
                        NetworkStatusBar(
                            isOnline: viewModel.isOnline,
                            onDismiss: viewModel.isOnline ? { viewModel.dismissNetworkStatus() } : nil
                        )
                        .animation(.easeInOut, value: viewModel.isOnline)
                    }
                    
                    SearchBar(
                        text: $viewModel.word,
                        isLoading: viewModel.isLoading
                    ) {
                        Task { await viewModel.search() }
                    }
                    .padding(.horizontal)
                    
                    if let definition = viewModel.definition {
                        ScrollView {
                            WordDefinitionCard(definition: definition, viewModel: viewModel)
                                .padding(.all)
                                .onTapGesture {
                                    viewModel.showDefinitionDetail(definition)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    } else if !viewModel.isLoading {
                        EmptyStateView(isOnline: viewModel.isOnline)
                    }
                    
                    Spacer()
                }
                
                // Loading Overlay
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .navigationTitle("Dictionary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    RecentSearchesButton(
                        isPresented: $viewModel.showPastSearches
                    )
                }
            }
            .sheet(isPresented: $viewModel.showPastSearches) {
                NavigationView {
                    RecentSearchesView(
                        viewModel: viewModel,
                        isOnline: viewModel.isOnline
                    )
                    .navigationTitle("Recent Searches")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                viewModel.showPastSearches = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showDetailView) {
                if let definition = viewModel.selectedDetailDefinition {
                    NavigationView {
                        WordDetailView(definition: definition, viewModel: viewModel)
                            .navigationBarItems(trailing: Button("Done") {
                                viewModel.showDetailView = false
                            })
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase != .active {
                    viewModel.stopAudio()
                }
            }
        }
    }
}
