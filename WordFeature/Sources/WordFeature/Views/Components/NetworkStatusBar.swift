import SwiftUI

struct NetworkStatusBar: View {
    let isOnline: Bool
    var visible: Bool = true
    
    var body: some View {
        VStack {
            if visible {
                HStack(spacing: 8) {
                    Image(systemName: isOnline ? "wifi" : "wifi.slash")
                        .foregroundColor(isOnline ? .green : .white)
                    Text(isOnline ? "You're online" : "You're offline")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(isOnline ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: visible)
                .animation(.easeInOut(duration: 0.3), value: isOnline)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: visible)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibility(identifier: "networkStatusBar")
        .accessibility(hint: Text(isOnline ? "Network connection restored" : "No network connection available"))
    }
}

#Preview {
    VStack(spacing: 20) {
        NetworkStatusBar(isOnline: true, visible: true)
        NetworkStatusBar(isOnline: false, visible: true)
    }
    .padding()
}
