//
//  EmptyRecentSearchesView.swift
//  WordFeature
//
//  Created by Mohamed Salah on 26/02/2025.
//

import SwiftUI
import Domain

struct EmptyRecentSearchesView: View {
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
