//
//  RecentSearchCell.swift
//  WordFeature
//
//  Created by Mohamed Salah on 26/02/2025.
//

import SwiftUI
import Domain

struct RecentSearchCell: View {
    let definition: WordDefinition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(definition.word)
                .font(.headline)
            
            if let phonetic = definition.phonetic {
                Text(phonetic)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let firstMeaning = definition.meanings.first,
               let firstDefinition = firstMeaning.definitions.first {
                Text(firstDefinition.definition)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}
