import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isLoading: Bool
    let onSubmit: () -> Void
    
    @FocusState private var isFocused: Bool
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            searchField
            
            if !text.isEmpty || isEditing {
                clearButton
            }
        }
        .animation(.easeInOut(duration: 0.2), value: text)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .scaleEffect(isEditing ? 0.9 : 1.0)
            
            TextField("Search word", text: $text)
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .onChange(of: isFocused) { _, newValue in
                    withAnimation {
                        isEditing = newValue
                    }
                }
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .transition(.scale.combined(with: .opacity))
            }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isEditing ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
    
    private var clearButton: some View {
        Button(action: {
            withAnimation {
                text = ""
                isFocused = false
            }
        }) {
            Text("Cancel")
                .foregroundColor(.blue)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""), isLoading: .constant(true)) {}
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
