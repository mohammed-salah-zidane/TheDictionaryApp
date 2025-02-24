import SwiftUI

/// A reusable component for displaying a list of tags with a title
public struct TagsSection: View {
    private let title: String
    private let tags: [String]
    private let color: Color
    private let maxDisplayedTags: Int
    
    public init(
        title: String,
        tags: [String],
        color: Color,
        maxDisplayedTags: Int = 5
    ) {
        self.title = title
        self.tags = tags
        self.color = color
        self.maxDisplayedTags = maxDisplayedTags
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(tags.prefix(maxDisplayedTags), id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if tags.count > maxDisplayedTags {
                    Text("+\(tags.count - maxDisplayedTags)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}
