import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let isLoading: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search word", text: $text)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .onSubmit(onSubmit)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if !text.isEmpty {
                Button("Search", action: onSubmit)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""), isLoading: false) {}
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
