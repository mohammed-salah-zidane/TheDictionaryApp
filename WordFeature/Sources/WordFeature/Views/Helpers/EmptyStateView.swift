import SwiftUI

struct EmptyStateView: View {
    let isOnline: Bool
    let onRecentSearchesTapped: (() -> Void)?
    
    init(isOnline: Bool, onRecentSearchesTapped: (() -> Void)? = nil) {
        self.isOnline = isOnline
        self.onRecentSearchesTapped = onRecentSearchesTapped
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isOnline ? "text.magnifyingglass" : "wifi.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .symbolEffect(.bounce, value: isOnline)
            
            Text(isOnline ? "Search for a word" : "No internet connection")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(isOnline ?
                 "Type a word above to see its definition" :
                 "Connect to the internet to search for new words")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if !isOnline {
                Button(action: {
                    onRecentSearchesTapped?()
                }) {
                    Label("Check Recent Searches", systemImage: "clock.arrow.circlepath")
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .padding(.top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .transition(.opacity)
    }
}
