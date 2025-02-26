import SwiftUI
import Domain

struct WordDefinitionCard: View {
    let definition: WordDefinition
    @ObservedObject var viewModel: WordDefinitionViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .center, spacing: 16) {
                Text(definition.word)
                    .font(.title2)
                    .bold()
                
                if let audioURL = definition.phonetics.first(where: { !($0.audio ?? "").isEmpty })?.audio {
                    AudioButton(
                        isPlaying: viewModel.isAudioPlaying,
                        action: {
                            viewModel.playAudio(from: audioURL)
                        }
                    )
                }
                
                Spacer()
            }
            
            // Phonetic
            if let phonetic = definition.phonetic {
                Text(phonetic)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // First meaning preview
            if let firstMeaning = definition.meanings.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text(firstMeaning.partOfSpeech.capitalized)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    
                    if let firstDefinition = firstMeaning.definitions.first {
                        Text(firstDefinition.definition)
                            .font(.body)
                            .lineLimit(2)
                    }
                }
            }
            
            // More details hint
            HStack {
                Spacer()
                Text("Tap for more details")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1),
                    lineWidth: 1
                )
        )
        .shadow(
            color: colorScheme == .dark ? .clear : .black.opacity(0.05),
            radius: 8,
            y: 2
        )
    }
}

struct AudioButton: View {
    let isPlaying: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.8
                action()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scale = 1.0
                }
            }
        }) {
            Image(systemName: isPlaying ? "speaker.wave.2.circle.fill" : "speaker.wave.2.circle")
                .foregroundColor(isPlaying ? .blue : .secondary)
                .font(.title3)
                .scaleEffect(scale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(isPlaying ? "Stop pronunciation" : "Play pronunciation")
    }
}
