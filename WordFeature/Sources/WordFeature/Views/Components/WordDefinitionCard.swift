import SwiftUI
import Domain

struct WordDefinitionCard: View {
    let definition: WordDefinition
    @ObservedObject var viewModel: WordDefinitionViewModel
    
    private var firstMeaning: Meaning? {
        definition.meanings.first { $0.partOfSpeech.lowercased() == "noun" } ?? definition.meanings.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            wordHeaderView
            phoneticView
            meaningView
            moreDetailsHint
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onDisappear {
            viewModel.stopAudio()
        }
    }
    
    private var wordHeaderView: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(definition.word)
                .font(.title2)
                .bold()
            
            audioButton
            
            Spacer()
        }
    }
    
    private var audioButton: some View {
        Group {
            if let audioURL = definition.phonetics.first(where: { !($0.audio ?? "").isEmpty })?.audio {
                Button(action: {
                    viewModel.playAudio(from: audioURL)
                }) {
                    Image(systemName: viewModel.isAudioPlaying ? "speaker.wave.2.circle.fill" : "speaker.wave.2.circle")
                        .foregroundColor(viewModel.isAudioPlaying ? .blue : .secondary)
                        .font(.title3)
                }
                .accessibilityLabel("Play pronunciation")
            }
        }
    }
    
    private var phoneticView: some View {
        Group {
            if let phonetic = definition.phonetic {
                Text(phonetic)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var meaningView: some View {
        Group {
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
        }
    }
    
    private var moreDetailsHint: some View {
        HStack {
            Spacer()
            Image(systemName: "info.circle")
                .foregroundColor(.secondary)
            Text("More details")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
