//
//  WordDetailView.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import SwiftUI
import Domain

struct WordDetailView: View {
    let definition: WordDefinition
    @ObservedObject var viewModel: WordDefinitionViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 16) {
                        Text(definition.word)
                            .font(.largeTitle)
                            .bold()
                        
                        if let audioURL = definition.phonetics.first(where: { !($0.audio ?? "").isEmpty })?.audio {
                            Button(action: {
                                viewModel.playAudio(from: audioURL)
                            }) {
                                Image(systemName: viewModel.isAudioPlaying ? "speaker.wave.2.circle.fill" : "speaker.wave.2.circle")
                                    .foregroundColor(viewModel.isAudioPlaying ? .blue : .secondary)
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    if let phonetic = definition.phonetic {
                        Text(phonetic)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Meanings Section
                ForEach(definition.meanings, id: \.partOfSpeech) { meaning in
                    VStack(alignment: .leading, spacing: 16) {
                        Text(meaning.partOfSpeech)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        
                        ForEach(meaning.definitions.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(index + 1). \(meaning.definitions[index].definition)")
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if let example = meaning.definitions[index].example {
                                    Text("Example: \"\(example)\"")
                                        .font(.subheadline)
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .padding(.leading)
                                }
                            }
                        }
                        
                        // Synonyms and Antonyms
                        let synonyms = meaning.definitions.flatMap { $0.synonyms }
                        let antonyms = meaning.definitions.flatMap { $0.antonyms }
                        
                        if !synonyms.isEmpty {
                            TagsSection(title: "Synonyms", tags: synonyms, color: .blue)
                        }
                        
                        if !antonyms.isEmpty {
                            TagsSection(title: "Antonyms", tags: antonyms, color: .red)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onDisappear {
            viewModel.stopAudio()
        }
    }
}
