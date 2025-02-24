//
//  PastSearchesView.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//


import SwiftUI
import Domain

public struct PastSearchesView: View {
    let pastSearches: [WordDefinition]
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Past Searches")
                .font(.headline)
                .padding(.leading)
            if pastSearches.isEmpty {
                Text("No past searches available.")
                    .foregroundColor(.gray)
                    .padding(.leading)
            } else {
                ForEach(pastSearches, id: \.word) { definition in
                    Text(definition.word)
                        .padding(.leading)
                }
            }
        }
        .padding(.top)
    }
}
