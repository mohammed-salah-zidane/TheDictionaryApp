import SwiftUI
import Domain

struct MeaningView: View {
    let meaning: Meaning
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(meaning.partOfSpeech)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(meaning.definitions.indices, id: \.self) { index in
                    DefinitionView(
                        index: index + 1,
                        definition: meaning.definitions[index]
                    )
                }
            }
            
            if !meaning.definitions.flatMap({ $0.synonyms }).isEmpty {
                TagsSection(
                    title: "Synonyms",
                    tags: meaning.definitions.flatMap({ $0.synonyms }),
                    color: .blue
                )
            }
            
            if !meaning.definitions.flatMap({ $0.antonyms }).isEmpty {
                TagsSection(
                    title: "Antonyms",
                    tags: meaning.definitions.flatMap({ $0.antonyms }),
                    color: .red
                )
            }
            
            Divider()
        }
    }
}
