//
//  WordDetailView.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import SwiftUI
import Domain

struct WordDetailView: View {
    @ObservedObject var viewModel: WordDefinitionViewModel
    let definition: WordDefinition
    
    // MARK: - Animation Properties
    @State private var audioButtonScale: CGFloat = 1.0
    @State private var showContent: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                headerSection
                    .padding(.horizontal)
                
                // Meanings Section
                meaningsSection
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            .padding(.vertical)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showContent = true
            }
        }
        .onDisappear {
            viewModel.stopAudio()
            showContent = false
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                Text(definition.word)
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                
                if let audioURL = definition.phonetics.first(where: { !($0.audio ?? "").isEmpty })?.audio {
                    audioButton(url: audioURL)
                }
                
                Spacer()
            }
            
            if let phonetic = definition.phonetic {
                Text(phonetic)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Audio Button
    private func audioButton(url: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                audioButtonScale = 0.8
                viewModel.playAudio(from: url)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    audioButtonScale = 1.0
                }
            }
        }) {
            Image(systemName: viewModel.isAudioPlaying ? "speaker.wave.2.circle.fill" : "speaker.wave.2.circle")
                .foregroundColor(viewModel.isAudioPlaying ? .blue : .secondary)
                .font(.title2)
                .scaleEffect(audioButtonScale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isAudioPlaying)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Play pronunciation")
    }
    
    // MARK: - Meanings Section
    private var meaningsSection: some View {
        ForEach(definition.meanings, id: \.partOfSpeech) { meaning in
            VStack(alignment: .leading, spacing: 16) {
                meaningHeader(meaning.partOfSpeech)
                definitionsList(meaning.definitions)
                synonymsAndAntonyms(meaning)
                
                Divider()
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
    
    private func meaningHeader(_ partOfSpeech: String) -> some View {
        Text(partOfSpeech.capitalized)
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.1))
            )
    }
    
    private func definitionsList(_ definitions: [Definition]) -> some View {
        ForEach(Array(definitions.enumerated()), id: \.offset) { index, def in
            VStack(alignment: .leading, spacing: 8) {
                Text("\(index + 1). \(def.definition)")
                    .fixedSize(horizontal: false, vertical: true)
                
                if let example = def.example {
                    Text("Example: \"\(example)\"")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.leading)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func synonymsAndAntonyms(_ meaning: Meaning) -> some View {
        let synonyms = meaning.definitions.flatMap { $0.synonyms }
        let antonyms = meaning.definitions.flatMap { $0.antonyms }
        
        return Group {
            if !synonyms.isEmpty {
                TagsSection(title: "Synonyms", tags: synonyms, color: .blue)
            }
            
            if !antonyms.isEmpty {
                TagsSection(title: "Antonyms", tags: antonyms, color: .red)
            }
        }
    }
}
