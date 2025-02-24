//
//  WordSearchView.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//


import SwiftUI
import Domain

public struct WordSearchView: View {
    @StateObject var viewModel: WordDefinitionViewModel
    
    public init(viewModel: WordDefinitionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter a word", text: $viewModel.word)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.trailing)
                    }
                }
                Button(action: { Task { await viewModel.search() } }) {
                    Text("Search")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if let definition = viewModel.definition {
                    ScrollView {
                        WordDetailView(definition: definition)
                    }
                } else {
                    Text("No definition available")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                PastSearchesView(pastSearches: viewModel.pastSearches)
            }
            .navigationTitle("Word Search")
        }
    }
}
