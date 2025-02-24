import SwiftUI
import Domain

struct DefinitionView: View {
    let index: Int
    let definition: Definition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(index). \(definition.definition)")
                .fixedSize(horizontal: false, vertical: true)
                .font(.body)
            
            if let example = definition.example {
                Text("\"\(example)\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading)
            }
        }
    }
}
