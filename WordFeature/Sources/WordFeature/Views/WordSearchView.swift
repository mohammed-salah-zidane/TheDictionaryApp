//
//  WordSearchView.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import SwiftUI
import Domain
import AVFoundation

public struct WordSearchView: View {
    @StateObject var viewModel: WordDefinitionViewModel
    
    public init(viewModel: WordDefinitionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
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
                    }
                } else if !viewModel.isLoading {
                    EmptyStateView()
                }
                
                Spacer()
            }
            .navigationTitle("Dictionary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    RecentSearchesButton(isPresented: $viewModel.showPastSearches)
                }
            }
            .sheet(isPresented: $viewModel.showPastSearches) {
                NavigationView {
                    RecentSearchesView(viewModel: viewModel)
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
        }
    }
}

// MARK: - Supporting Views
private struct SearchBar: View {
    @Binding var text: String
    let isLoading: Bool
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for a word", text: $text)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .onSubmit(onSearch)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if isLoading {
                ProgressView()
                    .padding(.leading, 8)
            }
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "text.book.closed")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("Enter a word to see its definition")
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
    }
}

private struct WordDefinitionCard: View {
    let definition: WordDefinition
    @ObservedObject var viewModel: WordDefinitionViewModel
    
    private var firstMeaning: Meaning? {
        // Get the first meaning that is a noun, or fallback to first meaning
        definition.meanings.first { $0.partOfSpeech.lowercased() == "noun" } ?? definition.meanings.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Word Title and Audio Button
            HStack(alignment: .center, spacing: 12) {
                Text(definition.word)
                    .font(.title2)
                    .bold()
                
                if let audioURL = definition.phonetics.first(where: { !($0.audio ?? "").isEmpty })?.audio {
                    Button(action: {
                        viewModel.playAudio(from: audioURL)
                    }) {
                        Image(systemName: viewModel.isAudioPlaying ? "speaker.wave.2.circle.fill" : "speaker.wave.2.circle")
                            .foregroundColor(viewModel.isAudioPlaying ? .blue : .secondary)
                            .font(.title3)
                    }
                }
                
                Spacer()
            }
            
            // Phonetic
            if let phonetic = definition.phonetic {
                Text(phonetic)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // First Meaning (Noun preferred)
            if let meaning = firstMeaning,
               let firstDefinition = meaning.definitions.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text(meaning.partOfSpeech)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(firstDefinition.definition)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            
            // Tap for more hint
            HStack {
                Spacer()
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                Text("More details")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onDisappear {
            viewModel.stopAudio()
        }
    }
}

private struct MeaningView: View {
    let meaning: Meaning
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(meaning.partOfSpeech)
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(meaning.definitions.indices, id: \.self) { index in
                    DefinitionView(
                        index: index + 1,
                        definition: meaning.definitions[index]
                    )
                }
            }
            
            // Show synonyms if available
            if !meaning.definitions.flatMap({ $0.synonyms }).isEmpty {
                SynonymsView(synonyms: meaning.definitions.flatMap({ $0.synonyms }))
            }
            
            if !meaning.definitions.flatMap({ $0.antonyms }).isEmpty {
                AntonymsView(antonyms: meaning.definitions.flatMap({ $0.antonyms }))
            }
            
            Divider()
        }
    }
}

private struct DefinitionView: View {
    let index: Int
    let definition: Definition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(index). \(definition.definition)")
                .fixedSize(horizontal: false, vertical: true)
            
            if let example = definition.example {
                Text("\"\(example)\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct SynonymsView: View {
    let synonyms: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Synonyms")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(synonyms.prefix(5), id: \.self) { synonym in
                    Text(synonym)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

private struct AntonymsView: View {
    let antonyms: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Antonyms")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(antonyms.prefix(5), id: \.self) { antonym in
                    Text(antonym)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

// Helper view for flowing layout of tags
struct FlowLayout: Layout {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            containerWidth: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            containerWidth: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(
                at: CGPoint(
                    x: bounds.minX + point.x,
                    y: bounds.minY + point.y
                ),
                proposal: .unspecified
            )
        }
    }
    
    private struct FlowResult {
        let size: CGSize
        let points: [CGPoint]
        
        init(containerWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
            var size = CGSize(width: containerWidth, height: 0)
            var points: [CGPoint] = []
            var lineHeight: CGFloat = 0
            var lineY: CGFloat = 0
            var lineX: CGFloat = 0
            
            for subview in subviews {
                let viewSize = subview.sizeThatFits(.unspecified)
                
                if lineX + viewSize.width > containerWidth && !points.isEmpty {
                    // Move to next line
                    lineY += lineHeight + spacing
                    lineHeight = 0
                    lineX = 0
                }
                
                points.append(CGPoint(x: lineX, y: lineY))
                lineHeight = max(lineHeight, viewSize.height)
                lineX += viewSize.width + spacing
                size.width = max(size.width, lineX)
            }
            
            size.height = lineY + lineHeight
            self.size = size
            self.points = points
        }
    }
}
