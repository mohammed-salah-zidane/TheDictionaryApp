//
//  WordDetailView.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//


import SwiftUI
import Domain

public struct WordDetailView: View {
    let definition: WordDefinition
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(definition.word)
                .font(.largeTitle)
                .bold()
            if let phonetic = definition.phonetic {
                Text("Phonetic: \(phonetic)")
                    .font(.subheadline)
            }
            if let origin = definition.origin {
                Text("Origin: \(origin)")
                    .font(.footnote)
            }
            ForEach(definition.meanings, id: \.partOfSpeech) { meaning in
                VStack(alignment: .leading) {
                    Text(meaning.partOfSpeech.capitalized)
                        .font(.headline)
                    ForEach(meaning.definitions, id: \.definition) { def in
                        VStack(alignment: .leading) {
                            Text(def.definition)
                            if let example = def.example {
                                Text("Example: \(example)")
                                    .italic()
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 5)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
    }
}
