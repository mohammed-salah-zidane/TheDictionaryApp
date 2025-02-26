import SwiftUI
import Domain

public struct RecentSearchesView: View {
    let pastSearches: [WordDefinition]
    let isOnline: Bool
    let onSelect: (WordDefinition) -> Void
    
    public init(
        pastSearches: [WordDefinition],
        isOnline: Bool,
        onSelect: @escaping (WordDefinition) -> Void
    ) {
        self.pastSearches = pastSearches
        self.isOnline = isOnline
        self.onSelect = onSelect
    }
    
    public var body: some View {
        Group {
            if pastSearches.isEmpty {
                EmptyRecentSearchesView()
            } else {
                List {
                    ForEach(pastSearches, id: \.word) { definition in
                        RecentSearchCell(definition: definition)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .leading
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelect(definition)
                            }
                    }
                }
            }
        }
    }
}
