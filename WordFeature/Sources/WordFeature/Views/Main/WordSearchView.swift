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
    
    // MARK: - Animation States
    @State private var isCardVisible = false
    
    public init(viewModel: WordDefinitionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("TheDictionaryApp")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        recentSearchesButton
                    }
                }
                .sheet(isPresented: $viewModel.showPastSearches) {
                    RecentSearchesSheetView(
                        pastSearches: viewModel.pastSearches,
                        isOnline: viewModel.isOnline,
                        onSelect: { definition in
                            viewModel.selectPastSearch(definition)
                        },
                        onDismiss: {
                            viewModel.showPastSearches = false
                        }
                    )
                }
                .sheet(item: .init(
                    get: { viewModel.selectedDetailDefinition },
                    set: { _ in viewModel.dismissDetailView() }
                )) { definition in
                    DetailSheetView(
                        definition: definition,
                        viewModel: viewModel,
                        onDismiss: {
                            viewModel.dismissDetailView()
                        }
                    )
                }
                .alert("Error",
                       isPresented: .init(
                        get: { viewModel.showErrorAlert },
                        set: { if !$0 { viewModel.showErrorAlert = false } }
                       ),
                       presenting: viewModel.errorMessage
                ) { _ in
                    Button("OK", role: .cancel) {
                        viewModel.showErrorAlert = false
                    }
                } message: { message in
                    Text(message)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase != .active {
                        viewModel.stopAudio()
                    }
                }
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack {
            VStack(spacing: 16) {
                networkStatusView
                searchBar
                contentView
                Spacer()
            }
            
            if viewModel.isLoading {
                LoadingOverlay()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.isLoading)
    }
    
    // MARK: - Subviews
    private var networkStatusView: some View {
        NetworkStatusBar(
            isOnline: viewModel.isOnline,
            visible: !viewModel.isOnline
        )
        .animation(.easeInOut, value: viewModel.isOnline)
    }
    
    private var searchBar: some View {
        SearchBar(
            text: $viewModel.word,
            isLoading: $viewModel.isLoading
        ) {
            withAnimation {
                isCardVisible = false
                Task {
                    await viewModel.search()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isCardVisible = true
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var contentView: some View {
        Group {
            if let definition = $viewModel.definition.wrappedValue {
                ScrollView {
                    WordDefinitionCard(definition: definition, viewModel: viewModel)
                        .padding(.all)
                        .onTapGesture {
                            viewModel.showDefinitionDetail(definition)
                        }
                        .opacity(isCardVisible ? 1 : 0)
                        .offset(y: isCardVisible ? 0 : 20)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .leading)),
                    removal: .opacity.combined(with: .move(edge: .trailing))
                ))
            } else if !viewModel.isLoading {
                EmptyStateView(
                    isOnline: viewModel.isOnline,
                    onRecentSearchesTapped: {
                        viewModel.showPastSearches = true
                    }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.definition)
    }
    
    private var recentSearchesButton: some View {
        Button(action: {
            viewModel.showPastSearches = true
        }) {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(.blue)
                .imageScale(.large)
                .accessibilityLabel("Recent Searches")
        }
    }
    
    // MARK: - Sheet Views
    private func RecentSearchesSheetView(pastSearches: [WordDefinition], isOnline: Bool, onSelect: @escaping (WordDefinition) -> Void, onDismiss: @escaping () -> Void) -> some View {
        NavigationView {
            RecentSearchesView(
                pastSearches: pastSearches,
                isOnline: isOnline,
                onSelect: { definition in
                    onSelect(definition)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isCardVisible = true
                    }
                }
            )
            .navigationTitle("Recent Searches")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func DetailSheetView(definition: WordDefinition, viewModel: WordDefinitionViewModel, onDismiss: @escaping () -> Void) -> some View {
        NavigationView {
            WordDetailView(viewModel: viewModel, definition: definition)
                .navigationBarItems(trailing: Button("Done") {
                    onDismiss()
                })
        }
    }
}
