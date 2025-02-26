import SwiftUI

struct RecentSearchesButton: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Recent", systemImage: "clock.arrow.circlepath")
        }
    }
}
