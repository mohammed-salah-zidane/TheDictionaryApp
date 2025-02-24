import SwiftUI

struct NetworkStatusBar: View {
    let isOnline: Bool
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isOnline ? "wifi" : "wifi.slash")
                .imageScale(.small)
            Text(isOnline ? "Back Online" : "You're offline")
                .font(.subheadline)
            Spacer()
            
            if isOnline {
                Button(action: { onDismiss?() }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                }
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isOnline ? Color.green.opacity(0.9) : Color.orange.opacity(0.9))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
