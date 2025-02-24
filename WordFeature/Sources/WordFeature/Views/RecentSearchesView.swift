import SwiftUI
import Domain

struct RecentSearchesView: View {
    @ObservedObject var viewModel: WordDefinitionViewModel
    
    var body: some View {
        Group {
            if viewModel.pastSearches.isEmpty {
                EmptyRecentSearchesView()
            } else {
                List {
                    ForEach(viewModel.pastSearches, id: \.word) { definition in
                        RecentSearchCell(definition: definition)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectPastSearch(definition)
                                viewModel.showPastSearches = false
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

private struct RecentSearchCell: View {
    let definition: WordDefinition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(definition.word)
                .font(.headline)
            
            if let firstMeaning = definition.meanings.first,
               let firstDefinition = firstMeaning.definitions.first {
                Text(firstDefinition.definition)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if let partOfSpeech = definition.meanings.first?.partOfSpeech {
                Text(partOfSpeech)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct EmptyRecentSearchesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Recent Searches")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Your search history will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
