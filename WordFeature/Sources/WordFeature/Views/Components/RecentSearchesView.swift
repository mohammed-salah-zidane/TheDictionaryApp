import SwiftUI
import Domain

struct RecentSearchesView: View {
    @ObservedObject var viewModel: WordDefinitionViewModel
    let isOnline: Bool
    
    var body: some View {
        Group {
            if viewModel.pastSearches.isEmpty {
                EmptyRecentSearchesView()
            } else {
                List {
                    if !isOnline {
                        offlineHeader
                    }
                    
                    ForEach(viewModel.pastSearches, id: \.word) { definition in
                        RecentSearchCell(
                            definition: definition,
                            isOnline: isOnline
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectPastSearch(definition)
                            viewModel.showPastSearches = false
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    if isOnline {
                        await viewModel.loadPastSearches()
                    }
                }
            }
        }
    }
    
    private var offlineHeader: some View {
        Section {
            HStack {
                Image(systemName: "wifi.slash")
                Text("Offline Mode")
                Spacer()
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
            .listRowBackground(Color.clear)
        }
    }
}

private struct RecentSearchCell: View {
    let definition: WordDefinition
    let isOnline: Bool
    @State private var showingRefreshButton = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(definition.word)
                    .font(.headline)
                
                Spacer()
                
                if isOnline && showingRefreshButton {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                        .imageScale(.small)
                }
            }
            
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
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation {
                showingRefreshButton = hovering && isOnline
            }
        }
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
